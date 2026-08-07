#include <arch/i386/interrupt/exception.h>
#include <arch/i386/interrupt/isr.h>
#include <arch/i386/interrupt/irq.h>
#include <stdio.h>

void interrupt_dispatch(struct regs *r)
{
	if (r->int_no < 32) {
		exception_panic_frame(r);
	}
	else if (r->int_no >= 32 && r->int_no < 48) {
		irq_dispatch(r);
		return;
	}

	kprintf("bad interrupt: %d\n", r->int_no);

	for (;;) {
		__asm__ volatile("cli\n"
				 "hlt");
	}
}
