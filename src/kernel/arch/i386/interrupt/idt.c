#include <arch/i386/interrupt/idt.h>
#include <arch/i386/stdint.h>

struct idt_entry idt[256];
struct idtr idt_ptr;

extern uint32_t isr_stub_table[256];

static void idt_set_gate(uint8_t num, uint32_t base, uint16_t sel,
			 uint8_t flags)
{
	idt[num].offset_low = (base & 0xFFFF);
	idt[num].offset_high = ((base >> 16) & 0xFFFF);

	idt[num].reserved_zero = 0;
	idt[num].selector = sel;
	idt[num].type_attribute = flags;
}

void idt_init(void)
{
	idt_ptr.limit = (sizeof(struct idt_entry) * 256) - 1;
	idt_ptr.base = (uint32_t)&idt;

	for (int i = 0; i < 256; i++) {
		idt_set_gate(i, isr_stub_table[i], 0x08, 0x8E);
	}

	idt_load((uint32_t)&idt_ptr);
}
