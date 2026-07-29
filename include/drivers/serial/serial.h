#ifndef DRIVERS_SERIAL_SERIAL_H
#define DRIVERS_SERIAL_SERIAL_H

// Function Prototypes
void serial_init(void);
void serial_putc(char c);
void serial_puts(const char *str);

#endif /* DRIVERS_SERIAL_SERIAL_H */
