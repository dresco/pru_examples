CC = /usr/bin/gcc
PRU_ASM = ~/pru_sdk/bin/pasm
DTC = ~/pru_sdk/bin/dtc

C_FLAGS += -Wall -O2 -mtune=cortex-a8 -march=armv7-a
C_FLAGS += -I ~/am335x_pru_package/pru_sw/app_loader/include
L_FLAGS += -L ~/am335x_pru_package/pru_sw/app_loader/lib

all:
	@echo ">> Generating PRU binary"
	$(PRU_ASM) -b follow.p
	@echo ">> Compiling ARM binary"
	$(CC) $(C_FLAGS) -c -o follow.o follow.c
	$(CC) $(L_FLAGS) -static -o follow follow.o -lpthread -lprussdrv
	@echo ">> Compiling device tree overlay"
	$(DTC) -O dtb -o follow-00A0.dtbo -b 0 -@ follow.dts
	
clean:
	rm -rf follow follow.o follow.bin 
    
