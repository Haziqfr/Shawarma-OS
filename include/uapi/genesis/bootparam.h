#ifndef UAPI_GENESIS_BOOTPARAM_H
#define UAPI_GENESIS_BOOTPARAM_H

// Includes
#include <arch/i386/stdint.h>

// Macros
#define E820_MAX_ENTRIES 128

// Types
struct boot_e820_entry {
	uint64_t addr;
	uint64_t size;
	uint32_t type;
} __attribute__((packed));

struct screen_info {
	uint64_t lfb_base;
	uint64_t lfb_size;

	uint16_t lfb_width;
	uint16_t lfb_height;
	uint16_t pitch;
	uint8_t lfb_depth;

	uint8_t red_pos;
	uint8_t red_size;

	uint8_t green_pos;
	uint8_t green_size;

	uint8_t blue_pos;
	uint8_t blue_size;

	uint8_t alpha_pos;
	uint8_t alpha_size;

	uint8_t _reserved0[33];
} __attribute__((packed));

typedef struct GenesisPage {
	uint32_t magic;
	uint16_t version;

	uint8_t e820_entries;

	uint8_t _reserved0;

	struct boot_e820_entry e820_table[E820_MAX_ENTRIES];

	struct screen_info screen_info;

	uint8_t _reserved1[1464];

} __attribute__((packed)) BootInfo;

#endif /* UAPI_GENESIS_BOOTPARAM_H */
