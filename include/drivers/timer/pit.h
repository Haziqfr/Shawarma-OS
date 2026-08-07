#ifndef DRIVERS_TIMER_PIT_H
#define DRIVERS_TIMER_PIT_H

// Includes
#include <arch/i386/stdint.h>

// Macro Constants
#define PIT_CHNL0_PORT 0x40
#define PIT_CMD_PORT 0x43

#define BASE_CLK 1193182

#define PIT_INIT 0x36 // 00110110b

// Function Prototypes
void pit_init(uint32_t frequency);


#endif /* DRIVERS_TIMER_PIT_H */
