#ifndef DRIVERS_TIMER_TIMER_H
#define DRIVERS_TIMER_TIMER_H

// Includes
#include <arch/i386/stdint.h>

// Function Prototypes
void timer_init(uint32_t hz);
void timer_tick(void);
uint64_t timer_get_ticks(void);
uint32_t timer_get_frequency(void);

#endif /* DRIVERS_TIMER_TIMER_H */
