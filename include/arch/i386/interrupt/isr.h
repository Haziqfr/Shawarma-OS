#ifndef ARCH_I386_ISR_H
#define ARCH_I386_ISR_H

// Includes
#include <arch/i386/stdint.h>

// Types
struct regs {
	uint32_t ds;

	uint32_t edi;
	uint32_t esi;
	uint32_t ebp;
	uint32_t esp;

	uint32_t ebx;
	uint32_t edx;
	uint32_t ecx;
	uint32_t eax;

	uint32_t int_no;
	uint32_t err_code;

	uint32_t eip;
	uint32_t cs;
	uint32_t eflags;
};

// Function Prototypes
void interrupt_dispatch(struct regs *r);

#endif /* ARCH_I386_ISR_H */
