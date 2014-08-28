//
// Minimal PRU example that reads the value on pin GPIO1_16 (pr1_pru0_pru_r31_14), 
// which is available on P8 Pin 16. Then writes the value to data memory where it
// can be read by the main procoessor.
//
// We set the pin for direct PRU access in the device tree overlay, allowing access within
// a single clock cycle.
//

// Define the entry point of the program
.origin 0
.entrypoint START

START:
    // Zero out r4
    ZERO &r4, 4

READ:
    // Read the input pin
    
    // Put r31 bit 14 in r4 bit 1
    LSR  r4, r31, 14

    // Mask out the rest of r4 (only works with 8-bit or shorter masks)
    AND  r4, r4, 0x01     
        
    // Store pin state in the PRU's data ram
    SBCO r4, c24, 0, 4

    JMP READ

