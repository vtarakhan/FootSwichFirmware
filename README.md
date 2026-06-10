# FootSwitch Firmware

This project contains firmware for a MIDI footswitch / foot controller based on the ATmega16 microcontroller. The firmware manages 8 presets, sends MIDI Program Change / Control Change messages, works with an LCD display, and stores settings in EEPROM.

## What it is

This project is intended to create a compact MIDI controller with:

- 8 preset buttons;
- PC / CC mode switching;
- expression control via ADC;
- a 16x2 LCD display;
- saving/loading banks in EEPROM.

The firmware is designed for an ATmega16 running at 4 MHz.

## Main features

- Sends MIDI Program Change (PC) and Control Change (CC);
- 8 independent presets;
- Switches between PC and CC operating modes;
- Supports expression control (CC #11);
- Stores up to 10 banks in EEPROM;
- Uses a 16x2 LCD interface.

## Technical specifications

- Microcontroller: ATmega16
- Clock frequency: 4 MHz
- LCD interface: 4-bit mode
- MIDI UART: 31250 baud
- LCD connected through PORTC

## Project structure

- `src/main.c` — main firmware logic
- `src/lcd.c` / `src/lcd.h` — HD44780 LCD driver
- `generate_eeprom.py` — post-build script for generating `.eep`
- `platformio.ini` — PlatformIO configuration for ATmega16

## Build requirements

You need to install:

- PlatformIO
- AVR-GCC / avr-libc
- USBasp (for flashing)

## How to build and flash

1. Install the PlatformIO dependencies.
2. Go to the project root.
3. Build the firmware:

   ```sh
   pio run
   ```

4. Flash the microcontroller:

   ```sh
   pio run -t upload
   ```

After the build, the `generate_eeprom.py` script automatically creates the EEPROM file in the `build/` directory.

## LCD pin mapping

The LCD pin mapping is already defined in `platformio.ini`:

- LCD D4..D7 → PC4..PC7
- LCD RS → PC0
- LCD RW → PC1
- LCD E → PC2

## Notes

- The firmware operates on MIDI channel 1.
- FX MIDI controller numbers are defined in `src/main.c`.
- EEPROM is used to store presets across 10 banks.

## Useful commands

```sh
pio run
pio run -t upload
pio device monitor
```
