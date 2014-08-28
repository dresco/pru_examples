// Minimal example of using the Beaglebone PRU to set an output pin
// to match the state of an input pin

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
    
    // Execute code on PRU
    printf("Executing follow pru code\n");
    prussdrv_exec_program (0, "follow.bin");

    // Wait for Ctrl-C
    signal(SIGINT, on_sigint);
    while (is_sigint == 0)
    {
    }
    
    // Disable PRU and close memory mapping
    prussdrv_pru_disable (0);
    prussdrv_exit ();
    
    return(0);
}

