#include <drivers/timer/timer.h>
#include <drivers/serial/serial.h>
#include <arch/i386/interrupt/pic.h>
#include <arch/i386/interrupt/idt.h>
#include <drivers/video/vga.h>

void kernel_main(void)
{
	idt_init();

	pic_init();

	timer_init(100);

	serial_init();

	__asm__ volatile("sti");

	vga_clear();
	vga_write("Hello again from ShawarmaOS\n");

	serial_puts("Hello from serial\n");


	for (;;) {
		__asm__ volatile("hlt");
	}

}
