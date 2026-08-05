#ifndef ARCH_I386_INTERRUPT_EXCEPTION_H
#define ARCH_I386_INTERRUPT_EXCEPTION_H

// Includes
#include <arch/i386/interrupt/isr.h>

// Function Prototypes
void exception_panic_frame(const struct regs *r);

#endif /* ARCH_I386_INTERRUPT_EXCEPTION_H */
