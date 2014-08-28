//
// Minimal PRU example that sets a recurring timer, and writes an incrementing
// value to data memory where it can be read by the main processor.
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
    
    // timer comparison value. 200000000 is 1 second.
    MOV r0, 200000000
    SBCO r0, CONST_IEP, IEP_REG_CMP0, 4

    // start IEP free running counter
    LBCO r0, CONST_IEP, IEP_REG_GLOBAL_CFG, 4
    SET r0, 0
    SBCO r0, CONST_IEP, IEP_REG_GLOBAL_CFG, 4
    
    // Zero out r4
    ZERO &r4, 4

    JMP UPDATE
    
IEP_WAIT_EVENT:
    LBCO r2, CONST_IEP, IEP_REG_CMP_STATUS, 4
    QBBC IEP_WAIT_EVENT, r2, 0
    SBCO 0, CONST_IEP, IEP_REG_CMP_STATUS, 4

    // Increment r4 by one
    ADD r4, r4, 1

UPDATE:
    // Store r4 in the PRU's data ram
    SBCO r4, c24, 0, 4

    JMP IEP_WAIT_EVENT

