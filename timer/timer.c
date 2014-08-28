// Minimal PRU example that sets a recurring timer, and writes an incrementing
// value to data memory where it can be read by the main processor

// Standard includes
#include <stdio.h>
#include <signal.h>

// PRUSS interface library
#include <prussdrv.h>
#include <pruss_intc_mapping.h>

static volatile unsigned int is_sigint = 0;

// signal handler
static void on_sigint(int x)
{
  is_sigint = 1;
}

int main (void)
{
    // Initialize the PRU
    printf("Initializing PRU\n");
    prussdrv_init ();
    
    // Open an event
    if (prussdrv_open(PRU_EVTOUT_0))
    {
        printf("prussdrv_open open failed\n");
        return -1;
    }
    
    // Get pointers to PRU local memory
    void *pruDataMem;
    prussdrv_map_prumem (PRUSS0_PRU0_DATARAM, &pruDataMem);
    unsigned int *pruData = (unsigned int *) pruDataMem;
        
    // Execute code on PRU
    printf("Executing timer pru code\n");
    prussdrv_exec_program (0, "timer.bin");

    // Wait for Ctrl-C
    signal(SIGINT, on_sigint);
    while (is_sigint == 0)
    {
        // Print out the value received from the PRU code
        printf("Value = %i\n", pruData[0]);
    }
    
    // Disable PRU and close memory mapping
    prussdrv_pru_disable (0);
    prussdrv_exit ();
    
    return(0);
}

