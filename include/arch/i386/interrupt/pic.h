#ifndef ARCH_I386_INTERRUPT_PIC_H
#define ARCH_I386_INTERRUPT_PIC_H

// Includes
#include <arch/i386/stdint.h>

// Macro Constants
#define MASTER_PIC_COMMAND 0x20
#define MASTER_PIC_DATA    0x21
#define SLAVE_PIC_COMMAND  0xA0
#define SLAVE_PIC_DATA     0xA1

#define PIC_ICW1_INIT   0x11 // 00010001b
#define PIC_ICW2_MASTER 0x20 // 00100000b
#define PIC_ICW2_SLAVE (PIC_ICW2_MASTER + 8)
#define PIC_ICW3_MASTER 0x04 // 00000100b
#define PIC_ICW3_SLAVE  0x02 // 00000010b
#define PIC_ICW4        0x01 // 00000001b

#define PIC_OCW2_EOI 0x20

// Function Prototypes
void pic_init(void);
void pic_send_eoi(uint8_t irq);

void pic_disable_irq(uint8_t irq);
void pic_enable_irq(uint8_t irq);
uint16_t pic_get_mask(void);
void pic_set_mask_all(uint16_t mask);

#endif /* ARCH_I386_INTERRUPT_PIC_H */
