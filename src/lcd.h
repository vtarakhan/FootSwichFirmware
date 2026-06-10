#ifndef LCD_H
#define LCD_H

#include <avr/io.h>

// Режими дисплея для lcd_init()
#define LCD_DISP_OFF             0x00
#define LCD_DISP_ON              0x0C  // Увімкнути дисплей, без курсору
#define LCD_DISP_ON_CURSOR       0x0E  // Увімкнути дисплей + курсор
#define LCD_DISP_ON_BLINK        0x0F  // Увімкнути дисплей + курсор що блимає

// Прототипи функцій
void lcd_init(uint8_t dispAttr);
void lcd_clrscr(void);
void lcd_home(void);
void lcd_gotoxy(uint8_t x, uint8_t y);
void lcd_putc(char c);
void lcd_puts(const char *s);
void lcd_command(uint8_t cmd);

#endif // LCD_H