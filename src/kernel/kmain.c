#include <drivers/serial/serial.h>
#include <arch/i386/idt.h>
#include <drivers/video/vga.h>
#include <stdio.h>
#include <stddef.h>

void kernel_main(void)
{
	char grade = 'A';
	char mesg[] = "Hello World lads";
	char *null = NULL;

	vga_clear();
	vga_write("Hello again from ShawarmaOS\n");

	serial_init();
	serial_putc('H');
	serial_putc('i');
	serial_putc('\n');

	serial_puts("Hello from serial\n");

	kprintf("[INFO] Kernel Grade: %c\n", grade);
	kprintf("[INFO] Kernel initialization 99.99%%\n");
	kprintf("Kernl wants to say: %s\n", mesg);
	kprintf("[TEST] Printing null variable: %s\n", null);
	kprintf("[TEST] Unknown specifier test %%x %x\n", 1234);

	idt_init();
}
