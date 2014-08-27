//
// Minimal PRU example that twiddles GPIO1_12 (pr1_pru0_pru_r30_14), 
// which is available on P8 Pin 12.
//
// We set the pin for direct PRU access in the device tree overlay, allowing access within
// a single clock cycle.
//
// Note that we are toggling bit 14 of register r30, however the XOR instruction has a maximum
// operand value of 255, so we have to reference it as bit 6 of byte 1 of register r30
//
// http://processors.wiki.ti.com/index.php/PRU_Assembly_Instructions#Bitwise_Exclusive_OR_.28XOR.29
//

// Define the entry point of the program
.origin 0
.entrypoint START

START:

LOOPY:
    // Toggle output pin
    XOR r30.b1, r30.b1, 1<<6
    
    // Delay 10 microseconds (200 MHz / 2 instructions = 10 ns per loop, 10 us = 1000 loops) 
    MOV r0, 1000

DELAY_10US:
    SUB r0, r0, 1
    QBNE DELAY_10US, r0, 0

    JMP LOOPY

