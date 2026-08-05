#include <drivers/serial/serial.h>
#include <arch/i386/interrupt/idt.h>
#include <drivers/video/vga.h>

void kernel_main(void)
{
	vga_clear();
	vga_write("Hello again from ShawarmaOS\n");

	serial_init();
	serial_putc('H');
	serial_putc('i');
	serial_putc('\n');

	serial_puts("Hello from serial\n");

	idt_init();
}
