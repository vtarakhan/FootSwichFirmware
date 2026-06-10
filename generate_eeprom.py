import os
Import subprocess
Import env

Def make_eeprom(source, target, env):
    # Отримуємо шляхи до файлу прошивки .elf та майбутнього .eep
    Elf_file = os.path.join(env.subst("$BUILD_DIR"), "firmware.elf")
    Eep_file = os.path.join(env.subst("$BUILD_DIR"), "firmware.eep")
    
    # Визначаємо шлях до інструменту avr-objcopy з пакета gcc-avr
    Objcopy = env.subst("$OBJCOPY")
    
    Print(f"--> Extracting EEPROM data to: {eep_file}")
    
    # Запускаємо команду копіювання секції .eeprom
    Cmd = [
        Objcopy,
        "-j", ".eeprom",
        "--set-section-flags=.eeprom=alloc,load",
        "--change-section-lma", ".eeprom=0",
        "--no-change-warnings",
        "-O", "ihex",
        Elf_file,
        Eep_file
    ]
    
    Subprocess.run(cmd)

# Реєструємо функцію для виконання ПІСЛЯ того, як збудується головний .elf файл
env.AddPostAction("$BUILD_DIR/${PROGNAME}.elf", make_eeprom)