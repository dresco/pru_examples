//
// PRU example that starts a periodic timer and reads the logic 
// level on pin GPIO1_16 (pr1_pru0_pru_r31_14) at each overflow.
// 
// Increments a counter if the pin state has transitioned from high to 
// low (falling edge).
// 
// After a set number of samples, writes the value to data memory where it
// can be read by the main processor, and resets the counter values to 0.
//

// References to the current TI PRU manual (spruhf8) should also be
// considered pointers to the similar section in the revision c
// AM335x manual (spruh73c), ie:
// spruhf8 AM335x PRU-ICSS Reference Guide 5.3.2.1.4
// spruh73c AM335x TRM 4.5.3.2.1.4

// spruhf8 AM335x PRU-ICSS Reference Guide 5.2.1
#define CONST_PRUCFG C4
#define CONST_PRUDRAM C24
#define CONST_IEP C26

// am335xPruReferenceGuide, table 190
// offsets from CONST_IEP
#define IEP_REG_GLOBAL_CFG 0x00
#define IEP_REG_GLOBAL_STATUS 0x04
#define IEP_REG_COMPEN 0x08
#define IEP_REG_COUNT 0x0c
#define IEP_REG_CMP_CFG 0x40
#define IEP_REG_CMP_STATUS 0x44
#define IEP_REG_CMP0 0x48

//
// r3 holds the current logic level
// r4 holds the previous logic level
// r5 holds the xor of r3 & r4
// r6 holds the current event counter
// r7 holds the current number of samples
// r8 holds the number of samples before data ram is updated
// r9 holds the xor of r7 & r8
//

// Define the entry point of the program
.origin 0
.entrypoint START

START:
    // setup IEP module
    // enable timer clock PRU_ICSS_CFG.CGR.IEP_CLK_EN=1
    LBCO r0, CONST_PRUCFG, 0x10, 4
    SET r0, 17
    SBCO r0, CONST_PRUCFG, 0x10, 4
    
    // Set increment value of 1
    MOV r0, (1 << 8) | (1 << 4)
    SBCO r0, CONST_IEP, IEP_REG_GLOBAL_CFG, 4
    
    // Disable compensation counter
    MOV r0, 0
    SBCO r0, CONST_IEP, IEP_REG_COMPEN, 4

    // Set counter to 0
    MOV r0, 0
    SBCO r0, CONST_IEP, IEP_REG_COUNT, 4
    
    // Compare registers enable
    // Counter reset enable
    MOV r0, (1 << 1) | (1 << 0)
    SBCO r0, CONST_IEP, IEP_REG_CMP_CFG, 4
    
    // timer comparison value. 200,000 is 1/1000th second.
    MOV r0, 200000
    SBCO r0, CONST_IEP, IEP_REG_CMP0, 4

    // start IEP free running counter
    LBCO r0, CONST_IEP, IEP_REG_GLOBAL_CFG, 4
    SET r0, 0
    SBCO r0, CONST_IEP, IEP_REG_GLOBAL_CFG, 4

    // Zero out r3 to r8 (24 bytes in total)
    ZERO &r3, 24
    
    // set number of iterations between each data ram update
    MOV r8, 1000

    // Store number of events in the PRU's data ram (zero at this point)
    SBCO r6, c24, 0, 4

    JMP SAMPLE

CHECK_COUNT:
    // Write frequency to data ram every 1000 samples (1 sec)

    // XOR the current number of samples and target number of samples (1000) 
    // store the result in r9
    XOR r9, r7, r8
    
    // r9 will only be 0 if r7 and r8 match (we have reached 1000 samples)
    // so just go wait for next sample if it's greater than 0
    QBLT IEP_WAIT_EVENT, r9, 0
    
    // Store r6 (number of events) in the PRU's data ram
    SBCO r6, c24, 0, 4

    // Zero out r6, and r7 (8 bytes in total)
    ZERO &r6, 8
    
IEP_WAIT_EVENT:
    LBCO r2, CONST_IEP, IEP_REG_CMP_STATUS, 4
    QBBC IEP_WAIT_EVENT, r2, 0
    SBCO 0, CONST_IEP, IEP_REG_CMP_STATUS, 4

    // increment sample counter
    ADD r7, r7, 1

SAMPLE:
    // Either we have just started, or the timer has expired
    
    // Put r31 bit 14 in r3 bit 1
    LSR  r3, r31, 14

    // Mask out the rest of r3 (only works with 8-bit or shorter masks)
    AND  r3, r3, 0x01     

    // store the result of XOR in r5
    // bit 0 will be 1 if state has changed since last sample
    XOR r5, r3, r4
    
    // update r4 with the current state, ready for next event
    MOV r4, r3
    
    // if pin state did not change, then just go wait for next sample
    QBBC CHECK_COUNT, r5.t0

    // pin state has changed, is it low (was falling edge)?
    // if not then, just go wait for next sample
    QBBS CHECK_COUNT, r3.t0
    
    // must be at falling edge, increment event counter
    ADD r6, r6, 1

    JMP CHECK_COUNT

