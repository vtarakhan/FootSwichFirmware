/*****************************************************
This program was produced by the
CodeWizardAVR V2.03.8a Evaluation
Automatic Program Generator
© Copyright 1998-2008 Pavel Haiduc, HP InfoTech s.r.l.
http://www.hpinfotech.com

Project : 
Version : 
Date    : 21.11.2008
Author  : Freeware, for evaluation and non-commercial use only
Company : 
Comments: 


Chip type           : ATmega16L
Program type        : Application
Clock frequency     : 4,000000 MHz
Memory model        : Small
External RAM size   : 0
Data Stack size     : 256
*****************************************************/

#include <mega16.h>

// Alphanumeric LCD Module functions
#asm
   .equ __lcd_port=0x15 ;PORTC
#endasm
#include <lcd.h>

#include <stdlib.h>
#include <delay.h>

// Standard Input/Output functions
#include <stdio.h>

#define BUTTON_DELAY 300 // ms


//номер миди контроллера для каждой функции устройства (можно сделать настраиваемым, но пока жестко закреплено)
#define TAPT 64// для тапа
#define FX1 65 // для остальных кнопок(кроме кнопок смены программ)
#define FX2 66
#define FX3 67
#define FX4 68
#define FX5 69

//Закрепление определенных функций за конкретными контактами мк
//конфигурационные кнопки
#define s_inc_sw    PINB.0
#define s_dec_sw    PINB.1
#define s_save_sw   PINB.2
#define s_load_sw   PINB.3
//кнопки смены программ(пресетов)
#define P1_sw       PINA.0
#define P2_sw       PINA.1
#define P3_sw       PINA.2
#define P4_sw       PINA.3
//кнопки управления миди контроллерами(эффектами и тд.)
#define FX1_sw       PINA.4
#define FX2_sw       PINA.5
#define FX3_sw       PINA.6
#define FX4_sw       PINA.7
#define FX5_sw       PIND.3//В моей железке не используется
#define TAPT_sw      PIND.2

//Пока поддерживается только 10 банков настроек
//Настройки хранятся в энергонезависимой памяти
//Эти значения(нули) запишутся в память при программировании, 
//далее при включении/выключении железяки будут хранить настроенное значение
eeprom unsigned char ucP1[10] = {0,0,0,0,0,0,0,0,0,0};
eeprom unsigned char ucP2[10] = {0,0,0,0,0,0,0,0,0,0};
eeprom unsigned char ucP3[10] = {0,0,0,0,0,0,0,0,0,0};
eeprom unsigned char ucP4[10] = {0,0,0,0,0,0,0,0,0,0};


//4 переключаемых программы(пресета)
unsigned char nPreset_1 = 0;
unsigned char nPreset_2 = 0;
unsigned char nPreset_3 = 0;
unsigned char nPreset_4 = 0;

//Текущие значения контроллеров
unsigned char ucFX1_sw = 0;
unsigned char ucFX2_sw = 0;
unsigned char ucFX3_sw = 0;
unsigned char ucFX4_sw = 0;
unsigned char ucFX5_sw = 0;
unsigned char ucTAPT_sw = 0;

//первый активный по умолчанию
int CurPreset = 1;

//первый банк грузится при включении
unsigned char nBnkNum = 1;


void MIDI_CC_send(char cCtrlNum, char cVal)
{
              putchar(0xB0);  //отправляем Control Change сообощение  (пока жестко в первый канал)
              putchar(cCtrlNum);  // с нужным номером миди контроллера
              putchar(cVal);  // и нужным значением
}

void MIDI_PC_send(char cPrgNum)
{
              putchar(0xC0);  //отправляем Program Change сообощение  (пока жестко в первый канал)
              putchar(cPrgNum);  // с нужным номером пресета
}

// External Interrupt 0 service routine
/*interrupt [EXT_INT0] void ext_int0_isr(void)// отработка нажатия tap tempo
{
              #asm("cli")
              
            if(ucTAPT_sw == 0)// Если был выключен - включить и наоборот
                ucTAPT_sw = 127;
            else
                ucTAPT_sw = 0;
            MIDI_CC_send(TAPT, ucTAPT_sw);   //отправить комманду
            lcd_clear();
            
                if(ucTAPT_sw == 0)// Если был выключен - включить и наоборот
                lcd_putchar('1');
            else
                lcd_putchar('2');        
            
            

                delay_ms(200);
//              MIDI_CC_send(TAPT, 0);
//              delay_ms(100);
              #asm("sei")
}*/


void redraw_main_window(void)// перерисовка рабочего окна для дисплея 16х2
{

       char cPreset_1[4];
       char cPreset_2[4];
       char cPreset_3[4];
       char cPreset_4[4];

       lcd_clear();
       lcd_putsf("1:"); // Рисуем номера пресетов
       itoa((nPreset_1 + 1), cPreset_1);
       lcd_puts(cPreset_1);

       lcd_gotoxy(11, 0);
       lcd_putsf("2:");
       itoa((nPreset_2 + 1), cPreset_2);
       lcd_puts(cPreset_2);

       lcd_gotoxy(0, 1);
       lcd_putsf("3:");
       itoa((nPreset_3 + 1), cPreset_3);
       lcd_puts(cPreset_3);

       lcd_gotoxy(11, 1);
       lcd_putsf("4:");
       itoa((nPreset_4+ 1), cPreset_4);
       lcd_puts(cPreset_4); 
       
        //убиваем старый курсор
         lcd_gotoxy(5, 0);
         lcd_putsf("      ");
         lcd_gotoxy(5, 1);
         lcd_putsf("      ");
  
        //рисуем новый
      switch (CurPreset)
       {
       		case 1:
                lcd_gotoxy(5, 0);
                lcd_putsf("<<<");
                break;
            case 2:
                lcd_gotoxy(8, 0);
                lcd_putsf(">>>");
    		    break;
            case 3:
                lcd_gotoxy(5, 1);
                lcd_putsf("<<<");
                break;
            case 4:
                lcd_gotoxy(8, 1);
                lcd_putsf(">>>");
    		    break;
       }
}

void redraw_save_window(void)// перерисовка конфигурационного окна для дисплея 16х2
{
       char cPreset_1[4];
       char cPreset_2[4];
       char cPreset_3[4];
       char cPreset_4[4];
       char cBnkNum[4];
       
       lcd_clear();
       lcd_putsf("Save to bank# ");
       itoa(nBnkNum, cBnkNum);
       lcd_puts(cBnkNum);

       lcd_gotoxy(0, 1);
       itoa(ucP1[nBnkNum - 1] + 1, cPreset_1);
       lcd_puts(cPreset_1);
       
       lcd_gotoxy(4, 1);
       itoa( ucP2[nBnkNum - 1] + 1, cPreset_2);
       lcd_puts(cPreset_2);
       
       lcd_gotoxy(8, 1);
       itoa(ucP3[nBnkNum - 1] + 1, cPreset_3);
       lcd_puts(cPreset_3);
       
       lcd_gotoxy(12, 1);
       itoa(ucP4[nBnkNum - 1] + 1, cPreset_4);
       lcd_puts(cPreset_4);
}

void redraw_load_window(void)// перерисовка конфигурационного окна для дисплея 16х2
{
       char cPreset_1[4];
       char cPreset_2[4];
       char cPreset_3[4];
       char cPreset_4[4];
       char cBnkNum[4];
       
       lcd_clear();
       lcd_putsf("Load bank# ");
       itoa(nBnkNum, cBnkNum);
       lcd_puts(cBnkNum);

       lcd_gotoxy(0, 1);
       itoa(ucP1[nBnkNum - 1] + 1, cPreset_1);
       lcd_puts(cPreset_1);
       
       lcd_gotoxy(4, 1);
       itoa( ucP2[nBnkNum - 1] + 1, cPreset_2);
       lcd_puts(cPreset_2);
       
       lcd_gotoxy(8, 1);
       itoa(ucP3[nBnkNum - 1] + 1, cPreset_3);
       lcd_puts(cPreset_3);
       
       lcd_gotoxy(12, 1);
       itoa(ucP4[nBnkNum - 1] + 1, cPreset_4);
       lcd_puts(cPreset_4);
}



// Declare your global variables here

void main(void)
{
// Declare your local variables here

// Input/Output Ports initialization
// Port A initialization
// Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In 
// State7=P State6=P State5=P State4=P State3=P State2=P State1=P State0=P 
PORTA=0xFF;
DDRA=0x00;

// Port B initialization
// Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In 
// State7=T State6=T State5=T State4=T State3=P State2=P State1=P State0=P 
PORTB=0x0F;
DDRB=0x00;

// Port C initialization
// Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In 
// State7=T State6=T State5=T State4=T State3=T State2=T State1=T State0=T 
PORTC=0x00;
DDRC=0x00;

// Port D initialization
// Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In 
// State7=T State6=T State5=T State4=T State3=P State2=P State1=T State0=T 
PORTD=0x0A;
DDRD=0x00;

// Timer/Counter 0 initialization
// Clock source: System Clock
// Clock value: Timer 0 Stopped
// Mode: Normal top=FFh
// OC0 output: Disconnected
TCCR0=0x00;
TCNT0=0x00;
OCR0=0x00;

// Timer/Counter 1 initialization
// Clock source: System Clock
// Clock value: Timer 1 Stopped
// Mode: Normal top=FFFFh
// OC1A output: Discon.
// OC1B output: Discon.
// Noise Canceler: Off
// Input Capture on Falling Edge
// Timer 1 Overflow Interrupt: Off
// Input Capture Interrupt: Off
// Compare A Match Interrupt: Off
// Compare B Match Interrupt: Off
TCCR1A=0x00;
TCCR1B=0x00;
TCNT1H=0x00;
TCNT1L=0x00;
ICR1H=0x00;
ICR1L=0x00;
OCR1AH=0x00;
OCR1AL=0x00;
OCR1BH=0x00;
OCR1BL=0x00;

// Timer/Counter 2 initialization
// Clock source: System Clock
// Clock value: Timer 2 Stopped
// Mode: Normal top=FFh
// OC2 output: Disconnected
ASSR=0x00;
TCCR2=0x00;
TCNT2=0x00;
OCR2=0x00;

// External Interrupt(s) initialization
// INT0: On
// INT0 Mode: Falling Edge
// INT1: Off
// INT2: Off
/*GICR|=0x40;
MCUCR=0x00;
MCUCSR=0x00;
GIFR=0x40;*/

MCUCR=0x00;
MCUCSR=0x00;

// Timer(s)/Counter(s) Interrupt(s) initialization
TIMSK=0x00;

// USART initialization
// Communication Parameters: 8 Data, 1 Stop, No Parity
// USART Receiver: Off
// USART Transmitter: On
// USART Mode: Asynchronous
// USART Baud Rate: 31250
UCSRA=0x00;
UCSRB=0x08;
UCSRC=0x86;
UBRRH=0x00;
UBRRL=0x07;

// Analog Comparator initialization
// Analog Comparator: Off
// Analog Comparator Input Capture by Timer/Counter 1: Off
ACSR=0x80;
SFIOR=0x00;

// LCD module initialization
lcd_init(16);

      lcd_putsf(" XanLab FS V1.2 "); //Превед
      delay_ms(1000);
      
      nPreset_1 = ucP1[nBnkNum - 1];
            if(nPreset_1 > 127) nPreset_1 = 0; //Если в памяти было что то больше чем 127,
            //предпологаем, что была память непроинициализированна, устанавливаем значения в 0
      nPreset_2 = ucP2[nBnkNum - 1];
            if(nPreset_2 > 127) nPreset_2 = 0;
      nPreset_3 = ucP3[nBnkNum - 1];
            if(nPreset_3 > 127) nPreset_3 = 0;
      nPreset_4 = ucP4[nBnkNum - 1];
            if(nPreset_4 > 127) nPreset_4 = 0;

      
      redraw_main_window();
      
      // Global enable interrupts
//#asm("sei")


while (1)
      {
        if (s_inc_sw == 0) //инкремент значения
         {
           #asm("cli")
          switch (CurPreset)
           {
                case 1:
                    if(nPreset_1 < 127)
                        nPreset_1++;
                    break;
                case 2:
                    if(nPreset_2 < 127)
                        nPreset_2++;
                    break;
                case 3:
                    if(nPreset_3 < 127)
                        nPreset_3++;
                    break;
                case 4:
                    if(nPreset_4 < 127)
                        nPreset_4++;
                    break;
                default: break;
           }
               redraw_main_window();
               delay_ms(BUTTON_DELAY);
           #asm("sei")
        };
        
        if (s_dec_sw == 0) // декремент значения
         {
           #asm("cli")
          switch (CurPreset)
           {
                case 1:
                    if(nPreset_1 > 0)
                        nPreset_1--;
                    break;
                case 2:
                    if(nPreset_2 > 0)
                        nPreset_2--;
                    break;
                case 3:
                    if(nPreset_3 > 0)
                        nPreset_3--;
                    break;
                case 4:
                    if(nPreset_4 > 0)
                        nPreset_4--;
                    break;
                default: break;
           }
               redraw_main_window();
               delay_ms(BUTTON_DELAY);
           #asm("sei")
        };
        
        if (s_save_sw == 0) // сохранение в банк
         {
          redraw_save_window();
           delay_ms(BUTTON_DELAY);
           while(s_save_sw == 0){};
                 while(1)
                 {
                  if ((s_inc_sw == 0) && (nBnkNum < 10)) //инкремент банка
                    {
                    #asm("cli")
                     nBnkNum++;
                     redraw_save_window();
                     delay_ms(BUTTON_DELAY);
                     #asm("sei")
                    }
                  if ((s_dec_sw == 0) && (nBnkNum > 1)) //декремент банка
                    {
                    #asm("cli")
                     nBnkNum--;
                     redraw_save_window();
                     delay_ms(BUTTON_DELAY);
                     #asm("sei")
                    }
                  if (s_save_sw == 0) //сохранить банк
                    {
                    #asm("cli")
                     ucP1[nBnkNum-1] = nPreset_1;
                     ucP2[nBnkNum-1] = nPreset_2;
                     ucP3[nBnkNum-1] = nPreset_3;
                     ucP4[nBnkNum-1] = nPreset_4;
                     redraw_main_window();
                     delay_ms(BUTTON_DELAY);
                     while(s_save_sw == 0){};
                     #asm("sei")
                     break;
                    }
                  }

         };
         
        if (s_load_sw == 0) // загрузка из банка
         {
           redraw_load_window();
           delay_ms(BUTTON_DELAY);
           while(s_load_sw == 0){};
                 while(1)
                 {
                  if ((s_inc_sw == 0) && (nBnkNum < 10)) //инкремент банка
                    {
                    #asm("cli")
                     nBnkNum++;
                     redraw_load_window();
                     delay_ms(BUTTON_DELAY);
                     #asm("sei")
                    }
                  if ((s_dec_sw == 0) && (nBnkNum > 1)) //декремент банка
                    {
                    #asm("cli")
                     nBnkNum--;
                     redraw_load_window();
                     delay_ms(BUTTON_DELAY);
                     #asm("sei")
                    }
                  if (s_load_sw == 0) //загрузить банк
                    {
                    #asm("cli")
                     nPreset_1 = ucP1[nBnkNum-1];
                        if(nPreset_1 > 127) nPreset_1 = 0;
                     nPreset_2 = ucP2[nBnkNum-1];
                        if(nPreset_2 > 127) nPreset_2 = 0;
                     nPreset_3 = ucP3[nBnkNum-1];
                        if(nPreset_3 > 127) nPreset_3 = 0;
                     nPreset_4 = ucP4[nBnkNum-1];
                        if(nPreset_4 > 127) nPreset_4 = 0;
                     CurPreset = 1;
                     MIDI_PC_send(nPreset_1);  // Включаем первый пресет
                     redraw_main_window();
                     delay_ms(BUTTON_DELAY);
                     while(s_load_sw == 0){};
                     #asm("sei")
                     break;
                    }
                  }
          }

        if (P1_sw == 0) // смена программы(пресета)
        {
        #asm("cli")
        MIDI_PC_send(nPreset_1);  // Включаем первый пресет
        CurPreset = 1;// изменяем номер активного пресета
        redraw_main_window(); 
        delay_ms(BUTTON_DELAY);
        while(P1_sw == 0){};
        #asm("sei")
        }

        if (P2_sw == 0) // смена программы(пресета)
        {
        #asm("cli")
        MIDI_PC_send(nPreset_2);  // Включаем пресет
        CurPreset = 2;// изменяем номер активного пресета
        redraw_main_window(); 
        delay_ms(BUTTON_DELAY);
        while(P2_sw == 0){};
        #asm("sei")       
        }

        if (P3_sw == 0) // смена программы(пресета)
        {
        #asm("cli")
        MIDI_PC_send(nPreset_3);  // Включаем пресет
        CurPreset = 3;// изменяем номер активного пресета
        redraw_main_window(); 
        delay_ms(BUTTON_DELAY);
        while(P3_sw == 0){};
        #asm("sei")        
        }

        if (P4_sw == 0) // смена программы(пресета)
        {
        #asm("cli")
        MIDI_PC_send(nPreset_4);  // Включаем пресет
        CurPreset = 4;// изменяем номер активного пресета
        redraw_main_window(); 
        delay_ms(BUTTON_DELAY);
        while(P4_sw == 0){};
        #asm("sei")        
        }

        if (FX1_sw == 0) // смена значения контроллера(вкл\выкл эффект)
        {
        #asm("cli")
            if(ucFX1_sw == 0)// Если был выключен - включить и наоборот
                ucFX1_sw = 127;
            else
                ucFX1_sw = 0;
            MIDI_CC_send(FX1, ucFX1_sw);   //отправить комманду
        delay_ms(BUTTON_DELAY);
        while(FX1_sw == 0){};
        #asm("sei")
        }

        if (FX2_sw == 0) // смена значения контроллера(вкл\выкл эффект)
        {
        #asm("cli")
            if(ucFX2_sw == 0)
                ucFX2_sw = 127;
            else
                ucFX2_sw = 0;
            MIDI_CC_send(FX2, ucFX2_sw); 
        delay_ms(BUTTON_DELAY);
        while(FX2_sw == 0){};
        #asm("sei")       
        }

        if (FX3_sw == 0) // смена значения контроллера(вкл\выкл эффект)
        {
        #asm("cli")
            if(ucFX3_sw == 0)
                ucFX3_sw = 127;
            else
                ucFX3_sw = 0;
            MIDI_CC_send(FX3, ucFX3_sw);
        delay_ms(BUTTON_DELAY);
        while(FX3_sw == 0){};
        #asm("sei")        
        }

        if (FX4_sw == 0) // смена значения контроллера(вкл\выкл эффект)
        {
        #asm("cli")
            if(ucFX4_sw == 0)
                ucFX4_sw = 127;
            else
                ucFX4_sw = 0;
            MIDI_CC_send(FX4, ucFX4_sw);
        delay_ms(BUTTON_DELAY);
        while(FX4_sw == 0){};
        #asm("sei")        
        }
        if (FX5_sw == 0) // смена значения контроллера(вкл\выкл эффект)
        {
        #asm("cli")
            if(ucFX5_sw == 0)
                ucFX5_sw = 127;
            else
                ucFX5_sw = 0;
            MIDI_CC_send(FX5, ucFX5_sw);
        delay_ms(BUTTON_DELAY);
        while(FX5_sw == 0){};
        #asm("sei")        
        }
        
       if (TAPT_sw == 0) // смена значения контроллера(вкл\выкл эффект)
        {
        #asm("cli")
            if(ucTAPT_sw == 0)
                ucTAPT_sw = 127;
            else
                ucTAPT_sw = 0;
            MIDI_CC_send(TAPT_sw, ucTAPT_sw);
        delay_ms(200);
        while(TAPT_sw == 0){};
        #asm("sei")        
        }
      }
  };
