#ifndef ARCH_I386_INTERRUPT_IRQ_H
#define ARCH_I386_INTERRUPT_IRQ_H

// Includes
#include <arch/i386/interrupt/isr.h>

// Types
typedef void (*irq_handler_t)(struct regs *);

// Macro Constants
#define IRQ_BASE 32

// Function Prototypes
void irq_dispatch(struct regs *r);
void irq_install_handler(uint8_t irq, irq_handler_t handler);

#endif /* ARCH_I386_INTERRUPT_IRQ_H */
