NAME = blink

# Paden naar de bestanden
SRC = $(NAME).s
OBJ = $(NAME).o
ELF = $(NAME).elf
HEX = $(NAME).hex
LDSCRIPT = $(NAME).ld

# Tools
AS = avr-as
LD = avr-ld
OBJCOPY = avr-objcopy
AVRDUDE = avrdude

# MCU en Programmeer Instellingen (Arduino Uno specificaties)
MCU = atmega328p
PORT = /dev/ttyACM0
BAUD = 115200
PROGRAMMER = arduino

# Compiler/Linker Vlaggen
ASFLAGS = -mmcu=$(MCU)
# We gebruiken jouw custom linker script in plaats van de hardcoded -Ttext vlag
LDFLAGS = -m avr5 -T $(LDSCRIPT)

# Standaard target
all: $(HEX)

# Assembleer de .S broncode naar een .o objectbestand
$(OBJ): $(SRC)
	$(AS) $(ASFLAGS) -o $(OBJ) $(SRC)

# Link het objectbestand met het linker-script naar een .elf bestand
$(ELF): $(OBJ) $(LDSCRIPT)
	$(LD) $(LDFLAGS) -o $(ELF) $(OBJ)

# Zet het .elf bestand om naar een .hex bestand voor de flash
$(HEX): $(ELF)
	$(OBJCOPY) -O ihex -R .eeprom $(ELF) $(HEX)

# Flash het .hex bestand naar de Arduino Uno
flash: $(HEX)
	$(AVRDUDE) -F -V -c $(PROGRAMMER) -p $(MCU) -P $(PORT) -b $(BAUD) -U flash:w:$(HEX):i

# Schoon de boel op
clean:
	rm -f $(OBJ) $(ELF) $(HEX)

.PHONY: all flash clean
