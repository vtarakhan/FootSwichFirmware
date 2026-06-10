import os
import subprocess

def make_eeprom(source, target, env):
    # Отримуємо шляхи до файлу прошивки .elf та майбутнього .eep
    elf_file = os.path.join(env.subst("$BUILD_DIR"), "firmware.elf")
    eep_file = os.path.join(env.subst("$BUILD_DIR"), "firmware.eep")
    
    # Визначаємо шлях до інструменту avr-objcopy з пакета gcc-avr
    objcopy = env.subst("$OBJCOPY")
    
    print(f"--> Extracting EEPROM data to: {eep_file}")
    
    # Запускаємо команду копіювання секції .eeprom
    cmd = [
        objcopy,
        "-j", ".eeprom",
        "--set-section-flags=.eeprom=alloc,load",
        "--change-section-lma", ".eeprom=0",
        "--no-change-warnings",
        "-O", "ihex",
        elf_file,
        eep_file
    ]
    
    subprocess.run(cmd)

# Реєструємо функцію для виконання ПІСЛЯ того, як збудується головний .elf файл
# Використовуємо глобальну змінну 'env', яку PlatformIO автоматично прокидає в скрипт
global env
env.AddPostAction("$BUILD_DIR/${PROGNAME}.elf", make_eeprom)