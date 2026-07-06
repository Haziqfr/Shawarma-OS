#define COM1_PORT 0x3F8

#include <drivers/serial/serial.h>
#include <arch/i386/io.h>

void serial_init(void)
{
	outb(COM1_PORT + 1, 0x00); // Disable all interrupts
	outb(COM1_PORT + 3, 0x80); // Enable DLAB
	outb(COM1_PORT + 0, 0x03);
	outb(COM1_PORT + 1, 0x00);
	outb(COM1_PORT + 3, 0x03);
	outb(COM1_PORT + 2, 0xC7);
	outb(COM1_PORT + 4, 0x03);
}

void serial_putc(char c)
{
	if (c == '\n') {
		serial_putc('\r');
	}

	while ((inb(COM1_PORT + 5) & 0x20) == 0)
		;
	outb(COM1_PORT, c);
}

void serial_puts(const char *str)
{
	for (int i = 0; str[i] != '\0'; i++) {
		serial_putc(str[i]);
	}
}