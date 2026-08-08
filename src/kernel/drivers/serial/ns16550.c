#include <drivers/serial/serial.h>
#include <arch/i386/io.h>


void ns16550_init(void)
{
	outb(COM1_PORT + IER, 0x00); // Disable all interrupts initially
	outb(COM1_PORT + LCR, 0x80); // Enable DLAB
	outb(COM1_PORT + DLL, 0x03);
	outb(COM1_PORT + DLM, 0x00);
	outb(COM1_PORT + LCR, 0x03); // Disable DLAB, 8N1
	outb(COM1_PORT + FCR, 0xC7);
	outb(COM1_PORT + MCR, 0x0B);

}

