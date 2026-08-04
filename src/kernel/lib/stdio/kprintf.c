#include <stdio.h>
#include <stdarg.h>
#include <stdbool.h>
#include <console.h>
#include <arch/i386/stdint.h>

// ceil(2^37 / 100) = 1374389535 = 0x51EB851F
#define MAGIC_MULTIPLIER_100 0x51EB851FULL

static const char hex_lower_lut[] = "0123456789abcdef";
static const char digit_lut[] = "0001020304050607080910111213141516171819"
			     "2021222324252627282930313233343536373839"
			     "4041424344454647484950515253545556575859"
			     "6061626364656667686970717273747576777879"
			     "8081828384858687888990919293949596979899";

// Function Prototypes
static void formatter(va_list args, const char *format);
static void print_unsigned(uint32_t val);
static void print_signed(int32_t val);
static void print_hex(uint32_t val, bool alternate, uint8_t min_digits);
static void print_pointer(uintptr_t ptr);
static uint32_t fast_div100(uint32_t x);


static void formatter(va_list args, const char *format)
{
	while (*format) {
		if (*format != '%') {
			console_putc(*format);
			format++;
			continue;
		}

		format++;

		bool alternate = false;

		if (*format == '#') {
			alternate = true;
			format++;
		}

		switch (*format) {
		case 'c': {
			console_putc(va_arg(args, int));
			format++;
			break;
		}

		case 's': {
			const char *str = va_arg(args, const char *);
			if (!str)
				str = "(null)";

			while (*str) {
				console_putc(*str++);
			}
			format++;
			break;
		}

		case '%': {
			console_putc('%');
			format++;
			break;
		}

		case 'd':
		case 'i': {
			print_signed(va_arg(args, int32_t));
			format++;
			break;
		}

		case 'u': {
			print_unsigned(va_arg(args, uint32_t));
			format++;
			break;
		}

		case 'x': {
			print_hex(va_arg(args, uint32_t), alternate, 1);
			format++;
			break;
		}

		case 'p': {
			print_pointer(va_arg(args, uintptr_t));
			format++;
			break;
		}

		default: {
			console_putc('%');
			console_putc(*format++);
			break;
		}
		}
	}
}

void kprintf(const char *format, ...)
{
	va_list args;
	va_start(args, format);

	formatter(args, format);

	va_end(args);
}

static void print_unsigned(uint32_t val)
{
	uint8_t buffer[12];
	uint8_t pos = 12;

	if (!val) {
		console_putc('0');
		return;
	}

	while (val >= 100) {
		uint32_t quot100 = fast_div100(val);
		uint32_t rem100 = val - (quot100 * 100);
		val = quot100;

		buffer[--pos] = digit_lut[rem100 * 2 + 1];
		buffer[--pos] = digit_lut[rem100 * 2];
	}

	if (val < 10) {
		buffer[--pos] = (char)('0' + val);
	}

	else {
		buffer[--pos] = digit_lut[val * 2 + 1];
		buffer[--pos] = digit_lut[val * 2];
	}

	while (pos < 12) {
		console_putc((char)buffer[pos++]);
	}
}

static void print_signed(int32_t val)
{
	if (val < 0) {
		console_putc('-');
		print_unsigned((uint32_t)(-(int64_t)val));
		return;
	}

	print_unsigned((uint32_t)val);
}

static void print_hex(uint32_t val, bool alternate, uint8_t min_digits)
{
	if (alternate && val != 0) {
		console_putc('0');
		console_putc('x');
	}

	if (val == 0 && min_digits == 0) {
		console_putc('0');
		return;
	}

	char buffer[8];
	uint8_t pos = 8;

	while (val != 0) {
		buffer[--pos] = hex_lower_lut[val & 0xF];
		val >>= 4;
	}

	uint8_t digits_written = 8 - pos;
	while (digits_written < min_digits && pos > 0) {
		buffer[--pos] = '0';
		digits_written++;
	}


	while (pos < 8) {
		console_putc(buffer[pos++]);
	}
}


static void print_pointer(uintptr_t ptr)
{
	if (!ptr) {
		const char *nil_str = "(nil)";
		while (*nil_str) {
			console_putc(*nil_str++);
		}
		return;
	}
	print_hex((uint32_t)ptr, true, 8);
}


static uint32_t fast_div100(uint32_t x)
{
	return (uint32_t)(((uint64_t)x * MAGIC_MULTIPLIER_100) >> 37);
}

