#include <arch/i386/interrupt/pic.h>
#include <arch/i386/io.h>

void pic_init(void)
{
	// ICW1: Start initialization
	outb(MASTER_PIC_COMMAND, PIC_ICW1_INIT);
	outb(SLAVE_PIC_COMMAND, PIC_ICW1_INIT);

	// ICW2: Vector offsets
	outb(MASTER_PIC_DATA, PIC_ICW2_MASTER);
	outb(SLAVE_PIC_DATA, PIC_ICW2_SLAVE);

	// ICW3: Cascade wiring
	outb(MASTER_PIC_DATA, PIC_ICW3_MASTER);
	outb(SLAVE_PIC_DATA, PIC_ICW3_SLAVE);

	// ICW4: 8086 mode, normal EOI
	outb(MASTER_PIC_DATA, PIC_ICW4);
	outb(SLAVE_PIC_DATA, PIC_ICW4);

	// Disable all IRQs initially
	outb(MASTER_PIC_DATA, 0xFF);
	outb(SLAVE_PIC_DATA, 0xFF);
}

void pic_send_eoi(uint8_t irq)
{
	if (irq >= 16) {
		return;
	}

	if (irq >= 8) {
		outb(SLAVE_PIC_COMMAND, PIC_OCW2_EOI);
	}

	outb(MASTER_PIC_COMMAND, PIC_OCW2_EOI);
}

void pic_disable_irq(uint8_t irq)
{
	uint16_t port;
	uint8_t bit_index;

	if (irq >= 16) {
		return;
	}

	if (irq < 8) {
		port = MASTER_PIC_DATA;
		bit_index = irq;
	} else {
		port = SLAVE_PIC_DATA;
		bit_index = (irq - 8);
	}

	uint8_t current_mask = inb(port);

	outb(port, (current_mask | (1 << bit_index)));
}

void pic_enable_irq(uint8_t irq)
{
	uint16_t port;
	uint8_t bit_index;

	if (irq >= 16) {
		return;
	}

	if (irq < 8) {
		port = MASTER_PIC_DATA;
		bit_index = irq;
	} else {
		port = SLAVE_PIC_DATA;
		bit_index = (irq - 8);

		// Slave PIC interrupts travel through master's IRQ2.
		// Unmask cascade line before enabling slave IRQs.
		pic_enable_irq(2);
	}

	uint8_t current_mask = inb(port);

	outb(port, (current_mask & ~(1 << bit_index)));
}

void pic_set_mask_all(uint16_t mask)
{
	outb(MASTER_PIC_DATA, (uint8_t)(mask & 0xFF));
	outb(SLAVE_PIC_DATA, (uint8_t)((mask >> 8) & 0xFF));
}

uint16_t pic_get_mask(void)
{
	// Upper byte is Slave IMR; Lower byte is Master IMR
	return (uint16_t)(inb(SLAVE_PIC_DATA) << 8) | inb(MASTER_PIC_DATA);
}
