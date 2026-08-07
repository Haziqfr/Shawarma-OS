#include <drivers/timer/pit.h>
#include <arch/i386/stdint.h>
#include <arch/i386/io.h>



void pit_init(uint32_t frequency)
{

	outb(PIT_CMD_PORT, PIT_INIT);

	if (frequency == 0) {
		return;
	}

	uint32_t divisor_32 = BASE_CLK / frequency;

	// 65536 is represented as 0 in 16-bit PIT hardware registers
	if (divisor_32 >= 65536) {
		divisor_32 = 0;
	}

	uint16_t divisor = (uint16_t)(divisor_32 & 0xFFFF);


	outb(PIT_CHNL0_PORT, (uint8_t)(divisor & 0xFF));
	outb(PIT_CHNL0_PORT, (uint8_t)((divisor >> 8) & 0xFF));
}


