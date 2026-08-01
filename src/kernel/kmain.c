#include <drivers/serial/serial.h>
#include <arch/i386/idt.h>
#include <arch/i386/stdint.h>
#include <drivers/video/vga.h>
#include <stdio.h>
#include <stddef.h>


static void kprintf_test_suite(void);


void kernel_main(void)
{

	vga_clear();
	vga_write("Hello again from ShawarmaOS\n");

	serial_init();
	serial_putc('H');
	serial_putc('i');
	serial_putc('\n');

	serial_puts("Hello from serial\n");

	kprintf_test_suite();

	idt_init();
}

static void kprintf_test_suite(void)
{
	char grade = 'A';
	char mesg[] = "Hello World lads";
	char *null_ptr = NULL;


	kprintf("[INFO] Kernel Grade:         %c\n", grade);

	kprintf("[INFO] Kernel initialization 99.99%%\n");

	kprintf("Kernl wants to say:          %s\n", mesg);
	kprintf("[TEST] Printing null variable: %s\n", null_ptr);

	kprintf("[TEST] Unknown specifier test %%q %q\n", 1234);

	kprintf("[TEST] Unsigned Integer:     %u\n", 123654);
	kprintf("[TEST] UINT32 MAX:           %u\n", UINT32_MAX);
	kprintf("[TEST] Unsigned Zero:        %u\n", 0);

	kprintf("[TEST] Signed Integer:       %d\n", -567234);
	kprintf("[TEST] Signed Zero:          %d\n", 0);
	kprintf("[TEST] INT32 MAX:            %i\n", INT32_MAX);
	kprintf("[TEST] INT32 MIN:            %i\n", INT32_MIN);

	kprintf("[TEST] Hex value of 16:      %#x\n", 16);
	kprintf("[TEST] Hex value of 100:     %#x\n", 100);
	kprintf("[TEST] Hex value of 0:       %#x\n", 0);
	kprintf("[TEST] Value of 0xffffffff:  %#x\n", 0xffffffff);

	kprintf("[TEST] NULL Pointer:         %p\n", null_ptr);
	kprintf("[TEST] Stack Var Address:    %p\n", (void *)&grade);
	kprintf("[TEST] String In Buffer:     %p\n", (void *)mesg);
	kprintf("[TEST] Function Pointer:     %p\n", (void *)&kernel_main);
	kprintf("[TEST] Low Mem (VGA Buffer): %p\n", (void *)0xB8000);
}
