<B>Some simple PRU examples for BeagleBone Black</B>

To build these on a BBB, you'll need the following -

* GCC toolchain (apt get install build-essential)
* PRU assembler
* PRU app loader interface
* Device tree compiler

For the last three - I grabbed am335x_pru_package and pru_sdk from 
GitHub, and rebuilt any intel binaries for arm. The paths for the 
tools and libraries can be seen in the makefiles.

The device tree overlays enable the PRU, and assign direct control
of input & output pins as necessary for each example. While developing, 
I used kernel 3.8 with device tree overlay support and capemgr.

To load the overlay (using capemgr) -

* copy the generated .dtbo file to /lib/firmware/
* echo 'example_name' > /sys/devices/bone_capemgr*/slots
* dmesg will confirm whether it was loaded okay

If using a later kernel, you will (until device tree overlays are 
supported) need to rebuild the main device tree & reboot instead.
