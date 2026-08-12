#include <stdio.h>
#include <uapi/genesis/bootparam.h>
#include <drivers/timer/timer.h>
#include <drivers/serial/serial.h>
#include <arch/i386/interrupt/pic.h>
#include <arch/i386/interrupt/idt.h>
#include <drivers/video/vga.h>

/*
 * Magic = crc32("ShawarmaOS Boot Protocol")
 */
#define MAGIC 0x88FF1A3B

void kernel_main(BootInfo *boot)
{
	idt_init();

	pic_init();

	timer_init(100);

	serial_init();

	__asm__ volatile("sti");

	vga_clear();
	vga_write("Hello again from ShawarmaOS\n");

	serial_puts("Hello from serial\n");

	if (boot->magic != MAGIC) {
		kprintf("Invalid boot info. Go cry now");
		return;
	}

	kprintf("Boot Info is correct. Celebrate!!!");

	for (;;) {
		__asm__ volatile("hlt");
	}
}
