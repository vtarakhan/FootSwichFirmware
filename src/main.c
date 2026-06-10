#ifndef F_CPU
#define F_CPU 4000000UL
#endif

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include <avr/eeprom.h>
#include <avr/pgmspace.h>
#include <stdlib.h>
#include <stdio.h>

// Підключаємо завантажену через lib_deps бібліотеку Fleury LCD
#include "lcd.h"

#define BUTTON_DELAY 300 // ms
#define ADC_DELAY 30    // ms

// Номери MIDI контроллерів
#define FX1 64 
#define FX2 65
#define FX3 66
#define FX4 67
#define FX5 68
#define FX6 69
#define FX7 70
#define FX8 71
#define EXP 11

// Макрос для зчитування стану кнопки (Low рівень = Натиснуто)
#define GET_BIT(reg, bit) (!(reg & (1 << bit)))

// Прив'язка кнопок до пінів
#define s_inc_sw    GET_BIT(PINB, 0)
#define s_dec_sw    GET_BIT(PINB, 1)
#define s_save_sw   GET_BIT(PINB, 2)
#define s_load_sw   GET_BIT(PINB, 3)

#define P1_sw       GET_BIT(PINA, 0)
#define P2_sw       GET_BIT(PINA, 1)
#define P3_sw       GET_BIT(PINA, 2)
#define P4_sw       GET_BIT(PINA, 3)
#define P5_sw       GET_BIT(PINA, 4)
#define P6_sw       GET_BIT(PINA, 5)
#define P7_sw       GET_BIT(PINA, 6)
#define P8_sw       GET_BIT(PIND, 3)
#define PC_sw       GET_BIT(PIND, 4)

// Оголошення масивів у EEPROM пам'яті (стандарт AVR-GCC)
uint8_t EEMEM ucP1[10] = {9,0,0,0,0,0,0,0,0,0};
uint8_t EEMEM ucP2[10] = {11,0,0,0,0,0,0,0,0,0};
uint8_t EEMEM ucP3[10] = {12,0,0,0,0,0,0,0,0,0};
uint8_t EEMEM ucP4[10] = {13,0,0,0,0,0,0,0,0,0};
uint8_t EEMEM ucP5[10] = {11,0,0,0,0,0,0,0,0,0};
uint8_t EEMEM ucP6[10] = {13,0,0,0,0,0,0,0,0,0};
uint8_t EEMEM ucP7[10] = {9,0,0,0,0,0,0,0,0,0};
uint8_t EEMEM ucP8[10] = {12,0,0,0,0,0,0,0,0,0};

// Глобальні змінні в RAM
unsigned char nPreset_1 = 0;
unsigned char nPreset_2 = 0;
unsigned char nPreset_3 = 0;
unsigned char nPreset_4 = 0;
unsigned char nPreset_5 = 0;
unsigned char nPreset_6 = 0;
unsigned char nPreset_7 = 0;
unsigned char nPreset_8 = 0;
unsigned char ucPC_sw = 0;

unsigned char ucFX1_sw = 0;
unsigned char ucFX2_sw = 0;
unsigned char ucFX3_sw = 0;
unsigned char ucFX4_sw = 0;
unsigned char ucFX5_sw = 0;
unsigned char ucFX6_sw = 0;
unsigned char ucFX7_sw = 0;
unsigned char ucFX8_sw = 0;

unsigned int ADC_voltage = 0;
unsigned int ADC_voltage_old = 0;
int CurPreset = 1;
unsigned char nBnkNum = 1;

// Відправка байту через апаратний UART (заміна putchar)
void uart_putchar(char c) {
    while (!(UCSRA & (1 << UDRE))); // Очікуємо готовності буфера
    UDR = c;
}

void MIDI_CC_send(char cCtrlNum, char cVal) {
    uart_putchar(0xB0);  // Control Change (1 канал)
    uart_putchar(cCtrlNum);
    uart_putchar(cVal);
}

void MIDI_PC_send(char cPrgNum) {
    uart_putchar(0xC0);  // Program Change (1 канал)
    uart_putchar(cPrgNum);
}

// Функція для виводу текстових рядків безпосередньо з FLASH пам'яті (заміна lcd_putsf)
void lcd_putsf(const char *progmem_str) {
    char c;
    while ((c = pgm_read_byte(progmem_str++))) {
        lcd_putc(c);
    }
}

void redraw_main_window(void) {
    char buffer[4];

    lcd_clrscr();
    
    itoa((nPreset_1 + 1), buffer, 10); lcd_puts(buffer);

    lcd_gotoxy(4, 0);
    itoa((nPreset_2 + 1), buffer, 10); lcd_puts(buffer);
                
    lcd_gotoxy(7, 0);
    if (ucPC_sw == 0) lcd_putsf(PSTR("PC"));
    if (ucPC_sw == 1) lcd_putsf(PSTR("CC"));                 
       
    lcd_gotoxy(9, 0);
    itoa((nPreset_3 + 1), buffer, 10); lcd_puts(buffer);

    lcd_gotoxy(13, 0);
    itoa((nPreset_4 + 1), buffer, 10); lcd_puts(buffer);
       
    lcd_gotoxy(0, 1);
    itoa((nPreset_5 + 1), buffer, 10); lcd_puts(buffer);

    lcd_gotoxy(4, 1);
    itoa((nPreset_6 + 1), buffer, 10); lcd_puts(buffer);

    lcd_gotoxy(7, 1);
    lcd_putsf(PSTR("  "));
    itoa((nPreset_7 + 1), buffer, 10); lcd_puts(buffer);

    lcd_gotoxy(13, 1);
    itoa((nPreset_8 + 1), buffer, 10); lcd_puts(buffer); 
       
    // Очищення старих вказівників курсору
    lcd_gotoxy(3, 0);  lcd_putsf(PSTR(" ")); 
    lcd_gotoxy(12, 0); lcd_putsf(PSTR(" "));
    lcd_gotoxy(3, 1);  lcd_putsf(PSTR(" "));  
    lcd_gotoxy(12, 1); lcd_putsf(PSTR(" "));
  
    // Малювання нового курсору
    switch (CurPreset) {
        case 1: lcd_gotoxy(3, 0);  lcd_putsf(PSTR("<")); break;
        case 2: lcd_gotoxy(3, 0);  lcd_putsf(PSTR(">")); break;
        case 3: lcd_gotoxy(12, 0); lcd_putsf(PSTR("<")); break;
        case 4: lcd_gotoxy(12, 0); lcd_putsf(PSTR(">")); break;
        case 5: lcd_gotoxy(3, 1);  lcd_putsf(PSTR("<")); break;
        case 6: lcd_gotoxy(3, 1);  lcd_putsf(PSTR(">")); break;
        case 7: lcd_gotoxy(12, 1); lcd_putsf(PSTR("<")); break;
        case 8: lcd_gotoxy(12, 1); lcd_putsf(PSTR(">")); break;
    }
}

void redraw_save_window(void) {
    char cBnkNum[4];
    lcd_clrscr();
    lcd_putsf(PSTR("Save to bank# "));
    itoa(nBnkNum, cBnkNum, 10);
    lcd_puts(cBnkNum);
}

void redraw_load_window(void) {
    char cBnkNum[4];
    lcd_clrscr();
    lcd_putsf(PSTR("Load bank# "));
    itoa(nBnkNum, cBnkNum, 10);
    lcd_puts(cBnkNum);
}

int main(void) {
    // Ініціалізація портів ввода/виводу
    PORTA = 0xFF; DDRA = 0x00;
    PORTB = 0x0F; DDRB = 0x00;
    PORTC = 0x00; DDRC = 0x00;
    PORTD = 0x1A; DDRD = 0x00;

    // Таймери вимкнені за замовчуванням
    TCCR0 = 0x00; TCNT0 = 0x00; OCR0 = 0x00;
    TCCR1A = 0x00; TCCR1B = 0x00; TCNT1H = 0x00; TCNT1L = 0x00;
    ASSR = 0x00; TCCR2 = 0x00; TCNT2 = 0x00; OCR2 = 0x00;

    MCUCR = 0x00; MCUCSR = 0x00;
    TIMSK = 0x00;

    // USART налаштування: 8 Data, 1 Stop, No Parity, TX увімкнено, Швидкість 31250 бод при 4МГц
    UCSRA = 0x00;
    UCSRB = 0x08;
    UCSRC = (1 << URSEL) | (1 << UCSZ1) | (1 << UCSZ0); // замість 0x86
    UBRRH = 0x00;
    UBRRL = 0x07;

    // Аналоговий компаратор вимкнено, АЦП увімкнено
    ACSR = 0x80;
    SFIOR = 0x00;
    ADMUX = 7;
    ADCSRA = 0x87; // ADCSR в ATmega16 зветься ADCSRA

    // Ініціалізація дисплея
    lcd_init(LCD_DISP_ON);

    lcd_clrscr();
    lcd_putsf(PSTR("XanLab FS v2.0"));
    _delay_ms(1000);
      
    // Безпечне зчитування початкових значень з EEPROM
    nPreset_1 = eeprom_read_byte(&ucP1[nBnkNum - 1]); if(nPreset_1 > 127) nPreset_1 = 0;
    nPreset_2 = eeprom_read_byte(&ucP2[nBnkNum - 1]); if(nPreset_2 > 127) nPreset_2 = 0;
    nPreset_3 = eeprom_read_byte(&ucP3[nBnkNum - 1]); if(nPreset_3 > 127) nPreset_3 = 0;
    nPreset_4 = eeprom_read_byte(&ucP4[nBnkNum - 1]); if(nPreset_4 > 127) nPreset_4 = 0;
    nPreset_5 = eeprom_read_byte(&ucP5[nBnkNum - 1]); if(nPreset_5 > 127) nPreset_5 = 0;
    nPreset_6 = eeprom_read_byte(&ucP6[nBnkNum - 1]); if(nPreset_6 > 127) nPreset_6 = 0;
    nPreset_7 = eeprom_read_byte(&ucP7[nBnkNum - 1]); if(nPreset_7 > 127) nPreset_7 = 0;
    nPreset_8 = eeprom_read_byte(&ucP8[nBnkNum - 1]); if(nPreset_8 > 127) nPreset_8 = 0;
      
    redraw_main_window();

    while (1) {
        // Опитування Експресії (АЦП)
        ADCSRA |= 0x40; // Старт конверсії
        while (ADCSRA & 0x40); // Очікування завершення
        
        ADC_voltage = (ADCW >> 2) - 3;    
        if (ADC_voltage > 112) { 
            ADC_voltage = 127;
        }
        
        if (ADC_voltage != ADC_voltage_old) { 
            MIDI_CC_send(EXP, ADC_voltage);
            ADC_voltage_old = ADC_voltage;
            _delay_ms(ADC_DELAY); 
        }

        // Кнопка Increment (+)
        if (s_inc_sw) {
            cli();
            switch (CurPreset) {
                case 1: if(nPreset_1 < 127) nPreset_1++; break;
                case 2: if(nPreset_2 < 127) nPreset_2++; break;
                case 3: if(nPreset_3 < 127) nPreset_3++; break;
                case 4: if(nPreset_4 < 127) nPreset_4++; break;
                case 5: if(nPreset_5 < 127) nPreset_5++; break;
                case 6: if(nPreset_6 < 127) nPreset_6++; break;
                case 7: if(nPreset_7 < 127) nPreset_7++; break;  
                case 8: if(nPreset_8 < 127) nPreset_8++; break;
            }
            redraw_main_window();
            _delay_ms(BUTTON_DELAY);
            sei();
        }
        
        // Кнопка Decrement (-)
        if (s_dec_sw) {
            cli();
            switch (CurPreset) {
                case 1: if(nPreset_1 > 0) nPreset_1--; break;
                case 2: if(nPreset_2 > 0) nPreset_2--; break;
                case 3: if(nPreset_3 > 0) nPreset_3--; break;
                case 4: if(nPreset_4 > 0) nPreset_4--; break;  
                case 5: if(nPreset_5 > 0) nPreset_5--; break;
                case 6: if(nPreset_6 > 0) nPreset_6--; break;    
                case 7: if(nPreset_7 > 0) nPreset_7--; break;    
                case 8: if(nPreset_8 > 0) nPreset_8--; break;
            }
            redraw_main_window();
            _delay_ms(BUTTON_DELAY);
            sei();
        }
        
        // Функція збереження банку
        if (s_save_sw) {
            redraw_save_window();
            _delay_ms(BUTTON_DELAY);
            while(s_save_sw);
            while(1) {
                if (s_inc_sw && (nBnkNum < 10)) {
                    cli(); nBnkNum++; redraw_save_window(); _delay_ms(BUTTON_DELAY); sei();
                }
                if (s_dec_sw && (nBnkNum > 1)) {
                    cli(); nBnkNum--; redraw_save_window(); _delay_ms(BUTTON_DELAY); sei();
                }
                if (s_save_sw) {
                    cli();
                    eeprom_write_byte(&ucP1[nBnkNum-1], nPreset_1);
                    eeprom_write_byte(&ucP2[nBnkNum-1], nPreset_2);
                    eeprom_write_byte(&ucP3[nBnkNum-1], nPreset_3);
                    eeprom_write_byte(&ucP4[nBnkNum-1], nPreset_4);
                    eeprom_write_byte(&ucP5[nBnkNum-1], nPreset_5);
                    eeprom_write_byte(&ucP6[nBnkNum-1], nPreset_6);
                    eeprom_write_byte(&ucP7[nBnkNum-1], nPreset_7);
                    eeprom_write_byte(&ucP8[nBnkNum-1], nPreset_8);
                    redraw_main_window();
                    _delay_ms(BUTTON_DELAY);
                    while(s_save_sw);
                    sei();
                    break;
                }
            }
        }
         
        // Функція завантаження банку
        if (s_load_sw) {
            redraw_load_window();
            _delay_ms(BUTTON_DELAY);
            while(s_load_sw);
            while(1) {
                if (s_inc_sw && (nBnkNum < 10)) {
                    cli(); nBnkNum++; redraw_load_window(); _delay_ms(BUTTON_DELAY); sei();
                }
                if (s_dec_sw && (nBnkNum > 1)) {
                    cli(); nBnkNum--; redraw_load_window(); _delay_ms(BUTTON_DELAY); sei();
                }
                if (s_load_sw) {
                    cli();
                    nPreset_1 = eeprom_read_byte(&ucP1[nBnkNum-1]); if(nPreset_1 > 127) nPreset_1 = 0;
                    nPreset_2 = eeprom_read_byte(&ucP2[nBnkNum-1]); if(nPreset_2 > 127) nPreset_2 = 0;
                    nPreset_3 = eeprom_read_byte(&ucP3[nBnkNum-1]); if(nPreset_3 > 127) nPreset_3 = 0;
                    nPreset_4 = eeprom_read_byte(&ucP4[nBnkNum-1]); if(nPreset_4 > 127) nPreset_4 = 0;
                    nPreset_5 = eeprom_read_byte(&ucP5[nBnkNum-1]); if(nPreset_5 > 127) nPreset_5 = 0;
                    nPreset_6 = eeprom_read_byte(&ucP6[nBnkNum-1]); if(nPreset_6 > 127) nPreset_6 = 0;
                    nPreset_7 = eeprom_read_byte(&ucP7[nBnkNum-1]); if(nPreset_7 > 127) nPreset_7 = 0;
                    nPreset_8 = eeprom_read_byte(&ucP8[nBnkNum-1]); if(nPreset_8 > 127) nPreset_8 = 0;
                    CurPreset = 1;
                    MIDI_PC_send(nPreset_1);
                    redraw_main_window();
                    _delay_ms(BUTTON_DELAY);
                    while(s_load_sw);
                    sei();
                    break;
                }
            }
        }

        // Обробка пресетів P1 - P8
        if (P1_sw) { 
            cli();
            if (ucPC_sw == 0) {
                MIDI_PC_send(nPreset_1); CurPreset = 1; redraw_main_window(); _delay_ms(BUTTON_DELAY);
            } else {
                ucFX1_sw = (ucFX1_sw == 0) ? 127 : 0;
                MIDI_CC_send(FX1, ucFX1_sw); _delay_ms(BUTTON_DELAY);
            }   
            while(P1_sw); sei(); 
        }

        if (P2_sw) { 
            cli();
            if (ucPC_sw == 0) {
                MIDI_PC_send(nPreset_2); CurPreset = 2; redraw_main_window(); _delay_ms(BUTTON_DELAY);
            } else {
                ucFX2_sw = (ucFX2_sw == 0) ? 127 : 0;
                MIDI_CC_send(FX2, ucFX2_sw); _delay_ms(BUTTON_DELAY);
            } 
            while(P2_sw); sei();      
        }

        if (P3_sw) { 
            cli();
            if (ucPC_sw == 0) {
                MIDI_PC_send(nPreset_3); CurPreset = 3; redraw_main_window(); _delay_ms(BUTTON_DELAY);
            } else {
                ucFX3_sw = (ucFX3_sw == 0) ? 127 : 0;
                MIDI_CC_send(FX3, ucFX3_sw); _delay_ms(BUTTON_DELAY);
            } 
            while(P3_sw); sei();   
        }

        if (P4_sw) { 
            cli();
            if (ucPC_sw == 0) {
                MIDI_PC_send(nPreset_4); CurPreset = 4; redraw_main_window(); _delay_ms(BUTTON_DELAY);
            } else {
                ucFX4_sw = (ucFX4_sw == 0) ? 127 : 0;
                MIDI_CC_send(FX4, ucFX4_sw); _delay_ms(BUTTON_DELAY);
            } 
            while(P4_sw); sei();  
        }

        if (P5_sw) { 
            cli();
            if (ucPC_sw == 0) {
                MIDI_PC_send(nPreset_5); CurPreset = 5; redraw_main_window(); _delay_ms(BUTTON_DELAY);
            } else {
                ucFX5_sw = (ucFX5_sw == 0) ? 127 : 0;
                MIDI_CC_send(FX5, ucFX5_sw); _delay_ms(BUTTON_DELAY);
            }  
            while(P5_sw); sei();  
        }

        if (P6_sw) { 
            cli();
            if (ucPC_sw == 0) {
                MIDI_PC_send(nPreset_6); CurPreset = 6; redraw_main_window(); _delay_ms(BUTTON_DELAY);
            } else {
                ucFX6_sw = (ucFX6_sw == 0) ? 127 : 0;
                MIDI_CC_send(FX6, ucFX6_sw); _delay_ms(BUTTON_DELAY);
            }  
            while(P6_sw); sei();        
        }

        if (P7_sw) { 
            cli();
            if (ucPC_sw == 0) {
                MIDI_PC_send(nPreset_7); CurPreset = 7; redraw_main_window(); _delay_ms(BUTTON_DELAY);
            } else {
                ucFX7_sw = (ucFX7_sw == 0) ? 127 : 0;
                MIDI_CC_send(FX7, ucFX7_sw); _delay_ms(BUTTON_DELAY);
            }   
            while(P7_sw); sei(); 
        }
                    
        if (P8_sw) { 
            cli();
            if (ucPC_sw == 0) {
                MIDI_PC_send(nPreset_8); CurPreset = 8; redraw_main_window(); _delay_ms(BUTTON_DELAY);
            } else {
                ucFX8_sw = (ucFX8_sw == 0) ? 127 : 0;
                MIDI_CC_send(FX8, ucFX8_sw); _delay_ms(BUTTON_DELAY);
            } 
            while(P8_sw); sei();
        }  

        // Кнопка зміни режиму PC / CC
        if (PC_sw) {
            cli();
            ucPC_sw = (ucPC_sw == 0) ? 1 : 0;
            redraw_main_window();
            _delay_ms(200);
            while(PC_sw);
            sei();        
        }
    }
    return 0;
}