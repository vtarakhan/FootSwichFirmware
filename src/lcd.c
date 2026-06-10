#include "lcd.h"
#include <util/delay.h>

// Визначаємо регістри напрямку (DDR) та зчитування (PIN) на основі PORT
#define LCD_PORT_REG   _SFR_IO8(LCD_PORT)
#define LCD_DDR_REG    _SFR_IO8(LCD_PORT - 1)

#define LCD_CLR               0      // Дворядковий режим, очищення
#define LCD_MODE_DEFAULT      0x28   // 4-бітний режим, 2 рядки, 5x7 точок

static void lcd_toggle_e(void) {
    LCD_PORT_REG |= (1 << LCD_E_PIN);
    _delay_us(2);
    LCD_PORT_REG &= ~(1 << LCD_E_PIN);
    _delay_us(2);
}

static void lcd_write(uint8_t data, uint8_t rs) {
    if (rs) {
        LCD_PORT_REG |= (1 << LCD_RS_PIN);
    } else {
        LCD_PORT_REG &= ~(1 << LCD_RS_PIN);
    }
    LCD_PORT_REG &= ~(1 << LCD_RW_PIN); // Завжди Write (GND)

    // Старший нібл
    LCD_PORT_REG = (LCD_PORT_REG & 0x0F) | (data & 0xF0);
    lcd_toggle_e();

    // Молодший нібл
    LCD_PORT_REG = (LCD_PORT_REG & 0x0F) | ((data << 4) & 0xF0);
    lcd_toggle_e();

    _delay_us(50);
}

void lcd_command(uint8_t cmd) {
    lcd_write(cmd, 0);
}

void lcd_putc(char c) {
    lcd_write(c, 1);
}

void lcd_puts(const char *s) {
    while (*s) {
        lcd_putc(*s++);
    }
}

void lcd_clrscr(void) {
    lcd_command(0x01);
    _delay_ms(2);
}

void lcd_home(void) {
    lcd_command(0x02);
    _delay_ms(2);
}

void lcd_gotoxy(uint8_t x, uint8_t y) {
    if (y == 0) {
        lcd_command(0x80 + x);
    } else {
        lcd_command(0xC0 + x);
    }
}

void lcd_init(uint8_t dispAttr) {
    // Налаштування ліній на вихід
    LCD_DDR_REG |= (1 << LCD_DATA0_PIN) | (1 << LCD_DATA1_PIN) | 
                   (1 << LCD_DATA2_PIN) | (1 << LCD_DATA3_PIN) |
                   (1 << LCD_RS_PIN) | (1 << LCD_RW_PIN) | (1 << LCD_E_PIN);
    
    _delay_ms(16); // Очікування стабілізації живлення дисплея

    // Ініціалізація в 4-бітний режим
    LCD_PORT_REG = (LCD_PORT_REG & 0x0F) | 0x30;
    lcd_toggle_e();
    _delay_ms(5);
    lcd_toggle_e();
    _delay_us(200);
    lcd_toggle_e();
    
    LCD_PORT_REG = (LCD_PORT_REG & 0x0F) | 0x20; // Set 4-bit interface
    lcd_toggle_e();

    lcd_command(LCD_MODE_DEFAULT);
    lcd_command(dispAttr); // Просто передаємо обраний режим (наприклад, LCD_DISP_ON)
    lcd_clrscr();
}