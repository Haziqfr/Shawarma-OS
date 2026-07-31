#include <stdio.h>
#include <stdarg.h>
#include <console.h>

// Function Prototypes
static void formatter(va_list args, const char *format);

static void formatter(va_list args, const char *format)
{
	while (*format) {
		if (*format != '%') {
			console_putc(*format);
			format++;
			continue;
		}

		format++;

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
	va_list args_copy;


	va_start(args, format);
	va_copy(args_copy, args);

	formatter(args_copy, format);

	va_end(args);
	va_end(args_copy);
}
