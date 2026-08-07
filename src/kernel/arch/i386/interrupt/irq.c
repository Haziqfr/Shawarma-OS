#include <arch/i386/interrupt/irq.h>
#include <arch/i386/interrupt/pic.h>
#include <arch/i386/interrupt/isr.h>

static irq_handler_t irq_handlers[16];


void irq_dispatch(struct regs *r)
{
	uint8_t irq = r->int_no - IRQ_BASE;

	if (irq_handlers[irq]) {
		irq_handlers[irq](r);
	}

	pic_send_eoi(irq);
}

void irq_install_handler(uint8_t irq, irq_handler_t handler)
{
	if (irq < 16) {
		irq_handlers[irq] = handler;
	}
}
