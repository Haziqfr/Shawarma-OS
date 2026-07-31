#include <console.h>
#include <drivers/serial/serial.h>
#include <drivers/video/vga.h>

void console_putc(char c)
{
	vga_putc(c);
	serial_putc(c);
}