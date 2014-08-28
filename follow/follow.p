//
// Minimal PRU example that reads the level on pin GPIO1_16 (pr1_pru0_pru_r31_14), 
// and sets GPIO1_12 (pr1_pru0_pru_r30_14) to the same level.
//
// We set the pins for direct PRU access in the device tree overlay, allowing access
// within a single clock cycle.
//

// Define the entry point of the program
.origin 0
.entrypoint START

START:

READ:
    // Read the input pin
    
    // If r31 bit 14 is set, then jump to PINHIGH
    QBBS PINHIGH, r31, 14
    
    // Input pin must have been low, so clear the output pin
    CLR r30.t14

    JMP READ

PINHIGH:
    // Input pin must have been high, so set the output pin
    SET r30.t14

    JMP READ

