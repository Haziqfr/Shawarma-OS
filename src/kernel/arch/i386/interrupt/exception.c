#include <stdio.h>
#include <arch/i386/interrupt/isr.h>
#include <arch/i386/stdint.h>

static const char *const exception_messages[] = {
	"Division By Zero",
	"Debug",
	"Non Maskable Interrupt",
	"Breakpoint",
	"Overflow",
	"Bound Range Exceeded",
	"Invalid Opcode",
	"Device Not Available",
	"Double Fault",
	"Coprocessor Segment Overrun",
	"Invalid TSS",
	"Segment Not Present",
	"Stack Segment Fault",
	"General Protection Fault",
	"Page Fault",
	"Reserved",
	"x87 Floating Point",
	"Alignment Check",
	"Machine Check",
	"SIMD Floating Point",
};

static const char *exception_name(uint32_t int_no)
{
	if (int_no < sizeof(exception_messages) / sizeof(exception_messages[0]))
		return exception_messages[int_no];

	return "Unknown Exception";
}

void exception_panic_frame(const struct regs *r)
{
	kprintf("\n\n");
	kprintf("======== KERNEL PANIC ========\n\n");

	kprintf("Exception: %s\n", exception_name(r->int_no));
	kprintf("INT:       %u\n", r->int_no);
	kprintf("ERROR:     %#x\n", r->err_code);

	kprintf("\nRegisters:\n");

	kprintf("EAX: %#x  EBX: %#x\n", r->eax, r->ebx);
	kprintf("ECX: %#x  EDX: %#x\n", r->ecx, r->edx);

	kprintf("ESI: %#x  EDI: %#x\n", r->esi, r->edi);
	kprintf("EBP: %#x  ESP: %#x\n", r->ebp, r->esp);

	kprintf("\nExecution:\n");

	kprintf("EIP:    %#x\n", r->eip);
	kprintf("CS:     %#x\n", r->cs);
	kprintf("EFLAGS: %#x\n", r->eflags);

	kprintf("\n==============================\n");
}
