#include <arch/i386/stdint.h>
#include <stddef.h>
#include <string.h>

void *memcpy(void *dest, const void *src, size_t count)
{
	uint8_t *d = dest;
	const uint8_t *s = src;

	while (count--) {
		*d++ = *s++;
	}

	return dest;
}

void *memset(void *dest, int value, size_t count)
{
	uint8_t *dst = dest;

	while (count--) {
		*dst++ = (uint8_t)value;
	}

	return dest;
}

int memcmp(const void *lhs, const void *rhs, size_t count)
{
	const uint8_t *x = lhs;
	const uint8_t *y = rhs;

	while (count--) {
		if (*x != *y) {
			return *x - *y;
		}

		x++;
		y++;
	}

	return 0;
}

void *memmove(void *dest, const void *src, size_t count)
{
	uint8_t *d = dest;
	const uint8_t *s = src;

	if (d == s) {
		return dest;
	}

	if (d < s) {
		while (count--) {
			*d++ = *s++;
		}
	}

	else {
		d += count;
		s += count;

		while (count--) {
			*--d = *--s;
		}
	}

	return dest;
}

