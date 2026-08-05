#ifndef ARCH_I386_IDT_H
#define ARCH_I386_IDT_H

// Includes
#include <arch/i386/stdint.h>

// Types
struct idt_entry {
	uint16_t offset_low;
	uint16_t selector;
	uint8_t reserved_zero;
	uint8_t type_attribute;
	uint16_t offset_high;
} __attribute__((packed));

struct idtr {
	uint16_t limit;
	uint32_t base;
} __attribute__((packed));

// External Variables
extern struct idt_entry idt[256];

// External Functions
extern void idt_load(uint32_t ptr);

// Function Prototypes
void idt_init(void);

#endif /* ARCH_I386_IDT_H */
