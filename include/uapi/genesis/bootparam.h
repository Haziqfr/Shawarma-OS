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

typedef struct GenesisPage {
	uint32_t magic;
	uint16_t version;

	uint8_t e820_entries;

	uint8_t _reserved0;

	struct boot_e820_entry e820_table[E820_MAX_ENTRIES];

	uint8_t _reserved1[1528];

} __attribute__((packed)) BootInfo;

#endif /* UAPI_GENESIS_BOOTPARAM_H */
