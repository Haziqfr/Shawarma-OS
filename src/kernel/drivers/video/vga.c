#include <drivers/video/vga.h>
#include <arch/i386/stdint.h>

static uint16_t *vga = (uint16_t *)0xB8000;

static uint8_t row = 0;
static uint8_t col = 0;

static uint8_t color = 0x07;

static void vga_scroll(void)
{
	if (row >= 25) {
		for (int i = 0; i < 24 * 80; i++) {
			vga[i] = vga[i + 80];
		}

		for (int i = 24 * 80; i < 25 * 80; i++) {
			vga[i] = (color << 8) | ' ';
		}

		row = 24;
	}
}

void vga_clear(void)
{
	for (int i = 0; i < 80 * 25; i++) {
		vga[i] = (color << 8) | ' ';
	}

	row = 0;
	col = 0;
}

void vga_putc(char c)
{
	if (c == '\n') {
		row++;
		col = 0;
		vga_scroll();
		return;
	}

	vga[row * 80 + col] = (color << 8) | c;

	col++;

	if (col >= 80) {
		col = 0;
		row++;
	}

	vga_scroll();
}

void vga_write(const char *str)
{
	while (*str) {
		vga_putc(*str++);
	}
}
