#ifndef DRIVERS_SERIAL_SERIAL_H
#define DRIVERS_SERIAL_SERIAL_H

// Macro Constants

// x86 PC - NS16550
#define COM1_PORT 0x3F8
#define THR 0  // Write; Transmitter Holding Register
#define RHR 0  // Read; Register Holding Register
#define DLL 0  // Read/Write - DLAB must be set; Divisor Latch Least significant byte

#define IER 1  // Read/Write; Interrupt Enable Register
#define DLM 1  // Read/Write - DLAB must be set; Divisor Latch Most significant byte

#define ISR 2  // Read; Interrupt Status Register
#define FCR 2  // Write; FIFO Control Register

#define LCR 3  // Read/Write; Line Control Register
#define MCR 4  // Read/Write; Modem Control Register

#define LSR 5  // Read; Line Status Register
#define PSD 5  // Write - DLAB must be set; Prescaler Division

#define MSR 6  // Read; Modem Status Register
#define SPR 7  // Read/Write; Scratch Pad Register


// Function Prototypes
void serial_init(void);
void serial_putc(char c);
void serial_puts(const char *str);

#endif /* DRIVERS_SERIAL_SERIAL_H */
