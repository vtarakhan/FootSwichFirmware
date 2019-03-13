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

#include <mega16a.h>

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
#define ADC_DELAY 30 // ms


//номер миди контроллера для каждой функции устройства (можно сделать настраиваемым, но пока жестко закреплено)
#define FX1 64 // для остальных кнопок(кроме кнопок смены программ)
#define FX2 65
#define FX3 66
#define FX4 67
#define FX5 68
#define FX6 69
#define FX7 70
#define FX8 71
#define EXP 11

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
#define P5_sw       PINA.4
#define P6_sw       PINA.5
#define P7_sw       PINA.6
#define P8_sw       PIND.3
#define PC_sw       PIND.4

//Пока поддерживается только 10 банков настроек
//Настройки хранятся в энергонезависимой памяти
//Эти значения(нули) запишутся в память при программировании, 
//далее при включении/выключении железяки будут хранить настроенное значение
eeprom unsigned char ucP1[10] = {9,0,0,0,0,0,0,0,0,0};
eeprom unsigned char ucP2[10] = {11,0,0,0,0,0,0,0,0,0};
eeprom unsigned char ucP3[10] = {12,0,0,0,0,0,0,0,0,0};
eeprom unsigned char ucP4[10] = {13,0,0,0,0,0,0,0,0,0};
eeprom unsigned char ucP5[10] = {11,0,0,0,0,0,0,0,0,0};
eeprom unsigned char ucP6[10] = {13,0,0,0,0,0,0,0,0,0};
eeprom unsigned char ucP7[10] = {9,0,0,0,0,0,0,0,0,0};
eeprom unsigned char ucP8[10] = {12,0,0,0,0,0,0,0,0,0};


//4 переключаемых программы(пресета)
unsigned char nPreset_1 = 0;
unsigned char nPreset_2 = 0;
unsigned char nPreset_3 = 0;
unsigned char nPreset_4 = 0;
unsigned char nPreset_5 = 0;
unsigned char nPreset_6 = 0;
unsigned char nPreset_7 = 0;
unsigned char nPreset_8 = 0;
unsigned char ucPC_sw = 0;

//Текущие значения контроллеров
unsigned char ucFX1_sw = 0;
unsigned char ucFX2_sw = 0;
unsigned char ucFX3_sw = 0;
unsigned char ucFX4_sw = 0;
unsigned char ucFX5_sw = 0;
unsigned char ucFX6_sw = 0;
unsigned char ucFX7_sw = 0;
unsigned char ucFX8_sw = 0;
//char ADC_v[4];
unsigned int ADC_voltage = 0;
unsigned int ADC_voltage_old = 0;
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

void redraw_main_window(void)// перерисовка рабочего окна для дисплея 16х2
{

       char cPreset_1[4];
       char cPreset_2[4];
       char cPreset_3[4];
       char cPreset_4[4]; 
       char cPreset_5[4];
       char cPreset_6[4];
       char cPreset_7[4];
       char cPreset_8[4];

       lcd_clear();
       itoa((nPreset_1 + 1), cPreset_1);
       lcd_puts(cPreset_1);

       lcd_gotoxy(4, 0);
       itoa((nPreset_2 + 1), cPreset_2);
       lcd_puts(cPreset_2);
                
       lcd_gotoxy(7, 0);
       if (ucPC_sw == 0) lcd_putsf("PC");
       if (ucPC_sw == 1) lcd_putsf("CC");                 
       
       lcd_gotoxy(9, 0);
       itoa((nPreset_3 + 1), cPreset_3);
       lcd_puts(cPreset_3);

       lcd_gotoxy(13, 0);
       itoa((nPreset_4+ 1), cPreset_4);
       lcd_puts(cPreset_4);
       
       lcd_gotoxy(0, 1);
       itoa((nPreset_5 + 1), cPreset_5);
       lcd_puts(cPreset_5);

       lcd_gotoxy(4, 1);
       itoa((nPreset_6 + 1), cPreset_6);
       lcd_puts(cPreset_6);

       lcd_gotoxy(7, 1);
       lcd_putsf("  ");
       itoa((nPreset_7 + 1), cPreset_7);
       lcd_puts(cPreset_7);

       lcd_gotoxy(13, 1);
       itoa((nPreset_8+ 1), cPreset_8);
       lcd_puts(cPreset_8); 
       
        //убиваем старый курсор
         lcd_gotoxy(3, 0);
         lcd_putsf(" "); 
         lcd_gotoxy(12, 0);
         lcd_putsf(" ");
         lcd_gotoxy(3, 1);
         lcd_putsf(" ");  
         lcd_gotoxy(12, 1);
         lcd_putsf(" ");
  
        //рисуем новый
      switch (CurPreset)
       {
       		case 1:
                lcd_gotoxy(3, 0);
                lcd_putsf("<");
                break;
            case 2:
                lcd_gotoxy(3, 0);
                lcd_putsf(">");
    		    break;
            case 3:
                lcd_gotoxy(12, 0);
                lcd_putsf("<");
                break;
            case 4:
                lcd_gotoxy(12, 0);
                lcd_putsf(">");
    		    break;
            case 5:
                lcd_gotoxy(3, 1);
                lcd_putsf("<");
                break;
            case 6:
                lcd_gotoxy(3, 1);
                lcd_putsf(">");
    		    break;
            case 7:
                lcd_gotoxy(12, 1);
                lcd_putsf("<");
                break;
            case 8:
                lcd_gotoxy(12, 1);
                lcd_putsf(">");
    		    break;
       }
}

void redraw_save_window(void)// перерисовка конфигурационного окна для дисплея 16х2
{
       char cBnkNum[4];
       
       lcd_clear();
       lcd_putsf("Save to bank# ");
       itoa(nBnkNum, cBnkNum);
       lcd_puts(cBnkNum);

}


void redraw_load_window(void)// перерисовка конфигурационного окна для дисплея 16х2
{
       char cBnkNum[4];
       
       lcd_clear();
       lcd_putsf("Load bank# ");
       itoa(nBnkNum, cBnkNum);
       lcd_puts(cBnkNum);
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
PORTD=0x1A;
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
ADMUX=7;
ADCSR=0x87;



// LCD module initialization
lcd_init(16);

      lcd_putsf("XanLab FS v2.0"); //Превед
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
      nPreset_5 = ucP5[nBnkNum - 1];
            if(nPreset_5 > 127) nPreset_5 = 0;
      nPreset_6 = ucP6[nBnkNum - 1];
            if(nPreset_6 > 127) nPreset_6 = 0;
      nPreset_7 = ucP7[nBnkNum - 1];
            if(nPreset_7 > 127) nPreset_7 = 0;
      nPreset_8 = ucP8[nBnkNum - 1];
            if(nPreset_8 > 127) nPreset_8 = 0;
      
      redraw_main_window();
      
      // Global enable interrupts
//#asm("sei")


while (1)
      { 
        ADCSR |= 0x40;
        ADC_voltage = (ADCW>>2)-3;    
         if (ADC_voltage > 112)
           { ADC_voltage=127 ;}
        if ( ADC_voltage != ADC_voltage_old)
          { 
           MIDI_CC_send(EXP, ADC_voltage);
           //lcd_gotoxy(0, 0);
           //itoa(ADC_voltage, ADC_v);
           //lcd_puts(ADC_v);
            ADC_voltage_old = ADC_voltage;
            delay_ms(ADC_DELAY); 
          }
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
                case 5:
                    if(nPreset_5 < 127)
                        nPreset_5++;
                    break;
                case 6:
                    if(nPreset_6 < 127)
                        nPreset_6++;
                    break;
                case 7:
                    if(nPreset_7 < 127)
                        nPreset_7++;
                    break;  
                case 8:
                    if(nPreset_8 < 127)
                        nPreset_8++;
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
                case 5:
                    if(nPreset_5 > 0)
                        nPreset_5--;
                    break;
                case 6:
                    if(nPreset_6 > 0)
                        nPreset_6--;
                    break;    
                case 7:
                    if(nPreset_7 > 0)
                        nPreset_7--;
                    break;    
                case 8:
                    if(nPreset_8 > 0)
                        nPreset_8--;
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
                     ucP5[nBnkNum-1] = nPreset_5;
                     ucP6[nBnkNum-1] = nPreset_6;
                     ucP7[nBnkNum-1] = nPreset_7;
                     ucP8[nBnkNum-1] = nPreset_8;
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
                     nPreset_5 = ucP5[nBnkNum-1];
                        if(nPreset_5 > 127) nPreset_5 = 0;
                     nPreset_6 = ucP6[nBnkNum-1];
                        if(nPreset_6 > 127) nPreset_6 = 0;
                     nPreset_7 = ucP7[nBnkNum-1];
                        if(nPreset_7 > 127) nPreset_7 = 0;
                     nPreset_8 = ucP8[nBnkNum-1];
                        if(nPreset_8 > 127) nPreset_8 = 0;
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
        { #asm("cli")
         if (ucPC_sw == 0)
           {
            MIDI_PC_send(nPreset_1);  // Включаем пресет
            CurPreset = 1;// изменяем номер активного пресета
            redraw_main_window(); 
            delay_ms(BUTTON_DELAY);
             }
         else
         {
            if(ucFX1_sw == 0)// Если был выключен - включить и наоборот
                ucFX1_sw = 127;
            else
                ucFX1_sw = 0;
            MIDI_CC_send(FX1, ucFX1_sw);   //отправить комманду
            delay_ms(BUTTON_DELAY);
            }   
          while(P1_sw == 0){};
            #asm("sei") 
        }

        if (P2_sw == 0) // смена программы(пресета)
        { #asm("cli")
         if (ucPC_sw == 0)
           {
            MIDI_PC_send(nPreset_2);  // Включаем пресет
            CurPreset = 2;// изменяем номер активного пресета
            redraw_main_window(); 
            delay_ms(BUTTON_DELAY);
             }
         else
         {
            if(ucFX2_sw == 0)// Если был выключен - включить и наоборот
                ucFX2_sw = 127;
            else
                ucFX2_sw = 0;
            MIDI_CC_send(FX2, ucFX2_sw);   //отправить комманду
            delay_ms(BUTTON_DELAY);
            } 
            while(P2_sw == 0){};
            #asm("sei")      
        }

        if (P3_sw == 0) // смена программы(пресета)
        { #asm("cli")
         if (ucPC_sw == 0)
           {
            MIDI_PC_send(nPreset_3);  // Включаем пресет
            CurPreset = 3;// изменяем номер активного пресета
            redraw_main_window(); 
            delay_ms(BUTTON_DELAY);
            }
         else
         {
            if(ucFX3_sw == 0)// Если был выключен - включить и наоборот
                ucFX3_sw = 127;
            else
                ucFX3_sw = 0;
            MIDI_CC_send(FX3, ucFX3_sw);   //отправить комманду
            delay_ms(BUTTON_DELAY);
            } 
            while(P3_sw == 0){};
            #asm("sei")   
        }

        if (P4_sw == 0) // смена программы(пресета)
        { #asm("cli")
          if (ucPC_sw == 0)
           {
            MIDI_PC_send(nPreset_4);  // Включаем пресет
            CurPreset = 4;// изменяем номер активного пресета
            redraw_main_window(); 
            delay_ms(BUTTON_DELAY);
            while(P4_sw == 0){}; }
         else
         {
            if(ucFX4_sw == 0)// Если был выключен - включить и наоборот
                ucFX4_sw = 127;
            else
                ucFX4_sw = 0;
            MIDI_CC_send(FX4, ucFX4_sw);   //отправить комманду
            delay_ms(BUTTON_DELAY);
             } 
             while(P4_sw == 0){};
            #asm("sei")  
        }

        if (P5_sw == 0) // смена значения контроллера(вкл\выкл эффект)
        { #asm("cli")
        if (ucPC_sw == 0)
           {
            MIDI_PC_send(nPreset_5);  // Включаем пресет
            CurPreset = 5;// изменяем номер активного пресета
            redraw_main_window(); 
            delay_ms(BUTTON_DELAY);
            while(P5_sw == 0){};
           }
         else
         {
            if(ucFX5_sw == 0)// Если был выключен - включить и наоборот
                ucFX5_sw = 127;
            else
                ucFX5_sw = 0;
            MIDI_CC_send(FX5, ucFX5_sw);   //отправить комманду
            delay_ms(BUTTON_DELAY);
            }  
            while(P5_sw == 0){};
            #asm("sei")  
        }

        if (P6_sw == 0) // смена значения контроллера(вкл\выкл эффект)
        { #asm("cli")
         if (ucPC_sw == 0)
           {
            MIDI_PC_send(nPreset_6);  // Включаем пресет
            CurPreset = 6;// изменяем номер активного пресета
            redraw_main_window(); 
            delay_ms(BUTTON_DELAY);
            }
         else
         { if(ucFX6_sw == 0)// Если был выключен - включить и наоборот
                ucFX6_sw = 127;
            else
                ucFX6_sw = 0;
            MIDI_CC_send(FX6, ucFX6_sw);   //отправить комманду
            delay_ms(BUTTON_DELAY);
            }  
            while(P6_sw == 0){};
            #asm("sei")        
        }

        if (P7_sw == 0) // смена значения контроллера(вкл\выкл эффект)
        { #asm("cli")
         if (ucPC_sw == 0)
           {
            MIDI_PC_send(nPreset_7);  // Включаем пресет
            CurPreset = 7;// изменяем номер активного пресета
            redraw_main_window(); 
            delay_ms(BUTTON_DELAY);
           }
         else
         { if(ucFX7_sw == 0)// Если был выключен - включить и наоборот
                ucFX7_sw = 127;
            else
                ucFX7_sw = 0;
            MIDI_CC_send(FX7, ucFX7_sw);   //отправить комманду
            delay_ms(BUTTON_DELAY);
         }   
         while(P7_sw == 0){};
         #asm("sei") 
        }
                    
        if (P8_sw == 0 )
        { #asm("cli")
          if (ucPC_sw == 0)
           {
            MIDI_PC_send(nPreset_8);  // Включаем пресет
            CurPreset = 8;// изменяем номер активного пресета
            redraw_main_window(); 
            delay_ms(BUTTON_DELAY);}
         else
           { if(ucFX8_sw == 0)// Если был выключен - включить и наоборот
                ucFX8_sw = 127;
            else
                ucFX8_sw = 0;
            MIDI_CC_send(FX8, ucFX8_sw);   //отправить комманду
            delay_ms(BUTTON_DELAY);
          } 
          while(P8_sw == 0){};
          #asm("sei")
         }  
       /* if (P8_sw == 0) // смена значения контроллера(вкл\выкл эффект)
        {
        #asm("cli")
            if(ucFX4_sw == 0)
                ucFX4_sw = 127;
            else
                ucFX4_sw = 0;
            MIDI_CC_send(FX4, ucFX4_sw);
        delay_ms(BUTTON_DELAY);
        while(P8_sw == 0){};
        #asm("sei")        
        }     */

        
       if (PC_sw == 0) // смена значения контроллера(вкл\выкл эффект)
        {
        #asm("cli")
            if(ucPC_sw == 0)
                ucPC_sw = 1;
            else
                ucPC_sw = 0;
        redraw_main_window();
        delay_ms(200);
        while(PC_sw == 0){};
        #asm("sei")        
        }
     } 
  };
