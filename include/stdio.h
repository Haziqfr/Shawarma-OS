#ifndef SHAWARMAOS_STDIO_H
#define SHAWARMAOS_STDIO_H

// Includes
#include <stdarg.h>

// Function Prototypes
void puts(const char *str);
int putchar(char c);
void kprintf(const char *format, ...) __attribute__((format(printf, 1, 2)));

#endif /* SHAWARMAOS_STDIO_H */
