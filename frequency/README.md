frequency
=========

PRU example that starts a periodic timer and reads the logic level on pin 
GPIO1_16 (pr1_pru0_pru_r31_14) at each overflow.

Increments a counter if the pin state has transitioned from high to low (falling edge).

After set number of samples, writes the value to data memory where it can be read 
by the main processor, and resets the counter values to 0.

