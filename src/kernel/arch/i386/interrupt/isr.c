#include <arch/i386/interrupt/exception.h>
#include <arch/i386/interrupt/isr.h>

void interrupt_dispatch(struct regs *r)
{
	if (r->int_no < 32) {
		exception_panic_frame(r);
	}

	for (;;) {
		__asm__ volatile("cli\n"
				 "hlt");
	}
}
