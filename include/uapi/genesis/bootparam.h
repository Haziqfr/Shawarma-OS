#ifndef UAPI_GENESIS_BOOTPARAM_H
#define UAPI_GENESIS_BOOTPARAM_H

// Includes
#include <arch/i386/stdint.h>

// Macros
#define E820_MAX_ENTRIES 128

// Types
struct boot_e820_entry {
	uint64_t addr; /* 0x00 */
	uint64_t size; /* 0x08 */
	uint32_t type; /* 0x10 */
} __attribute__((packed));

struct screen_info {
	uint64_t lfb_base;   /* 0x00 */
	uint64_t lfb_size;   /* 0x08 */

	uint16_t lfb_width;  /* 0x10 */
	uint16_t lfb_height; /* 0x12 */
	uint16_t pitch;      /* 0x14 */
	uint8_t lfb_depth;   /* 0x16 */

	uint8_t red_pos;     /* 0x17 */
	uint8_t red_size;    /* 0x18 */

	uint8_t green_pos;   /* 0x19 */
	uint8_t green_size;  /* 0x1A */

	uint8_t blue_pos;    /* 0x1B */
	uint8_t blue_size;   /* 0x1C */

	uint8_t reserved_pos; /* 0x1D */
	uint8_t reserved_size; /*0x1E */

	uint8_t _reserved0[33]; /* 0x1F */
} __attribute__((packed));

_Static_assert(sizeof(struct screen_info) == 64,
	"screen_info must be 64 bytes");

typedef struct GenesisPage {
	uint32_t magic;          /* 0x000 */
	uint16_t version;        /* 0x004 */

	uint8_t e820_entries;    /* 0x006 */

	uint8_t _reserved0;      /* 0x007 */

	struct boot_e820_entry e820_table[E820_MAX_ENTRIES]; /* 0x008 */

	struct screen_info screen_info; /* 0xA08 */

	uint8_t _reserved1[1464]; /* 0xA48 */

} __attribute__((packed)) BootInfo;

_Static_assert(sizeof(BootInfo) == 4096,
	"GenesisPage must be 4096 bytes");

#endif /* UAPI_GENESIS_BOOTPARAM_H */
