#include <drivers/timer/timer.h>
#include <drivers/serial/serial.h>
#include <arch/i386/stdint.h>
#include <drivers/timer/pit.h>
#include <arch/i386/interrupt/irq.h>
#include <arch/i386/interrupt/pic.h>

static volatile uint64_t ticks = 0;
static uint32_t frequency;

static void timer_irq_handler(struct regs *r);


void timer_init(uint32_t hz)
{
	frequency = hz;

	irq_install_handler(0, timer_irq_handler);
	pit_init(hz);
	pic_enable_irq(0);
}


void timer_tick()
{
	ticks++;
}

uint64_t timer_get_ticks(void)
{
	return ticks;
}

uint32_t timer_get_frequency()
{
	return frequency;
}

static void timer_irq_handler(struct regs *r)
{
	(void)r;      // not used yet

	timer_tick();
}
