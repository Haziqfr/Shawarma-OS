#include <mm/pmm.h>
#include <stdio.h>
#include <uapi/genesis/bootparam.h>
#include <stddef.h>
#include <arch/i386/stdint.h>

#define ALIGN_UP(num, align) (((num) + ((align) - 1)) & ~((align) - 1))
#define PHYS_ADDR_LIMIT 0x100000000ULL

extern char _kernel_start[];
extern char _kernel_end[];

static uint8_t *bitmap;
static uint64_t bitmap_bytes;
static uint64_t next_free_byte = 0;

void pmm_init(BootInfo *boot_info)
{
	uint64_t highest_addr = 0;

	for (uint8_t i = 0; i < boot_info->e820_entries; i++) {
		memory_map_t *map = &boot_info->e820_table[i];

		if (map->type != USABLE) {
			continue;
		}

		uint64_t end = map->addr + map->size;

		if (end > highest_addr) {
			highest_addr = end;
		}
	}

	if (highest_addr > PHYS_ADDR_LIMIT) {
		highest_addr = PHYS_ADDR_LIMIT;
	}

	uint64_t total_pages = (highest_addr + PAGE_SIZE - 1) >> 12;
	bitmap_bytes = (total_pages + 7) >> 3;

	uint64_t bitmap_addr = 0;

	for (uint8_t i = 0; i < boot_info->e820_entries; i++) {
		memory_map_t *map = &boot_info->e820_table[i];

		if (map->type != USABLE) {
			continue;
		}

		uint64_t bitmap_start = ALIGN_UP(map->addr, PAGE_SIZE);
		if (bitmap_start < 0x100000)
			bitmap_start = 0x100000;

		uint64_t map_end = map->addr + map->size;

		if (bitmap_start + bitmap_bytes <= map_end) {
			if (bitmap_start < (uintptr_t)_kernel_end &&
			    bitmap_start + bitmap_bytes >
				    (uintptr_t)_kernel_start) {
				bitmap_start = ALIGN_UP((uintptr_t)_kernel_end,
							PAGE_SIZE);
			}

			if (bitmap_start + bitmap_bytes <= map_end) {
				bitmap_addr = bitmap_start;
				break;
			}
		}
	}

	bitmap = (uint8_t *)bitmap_addr;
	kprintf("[INFO] Bitmap address: %p\n", bitmap);

	for (uint64_t i = 0; i < bitmap_bytes; i++) {
		bitmap[i] = 0xFF;
	}

	for (uint8_t i = 0; i < boot_info->e820_entries; i++) {
		memory_map_t *map = &boot_info->e820_table[i];

		if (map->type != USABLE) {
			continue;
		}

		uint64_t end = map->addr + map->size;
		if (end > highest_addr) {
			end = highest_addr;
		}

		for (uint64_t addr = ALIGN_UP(map->addr, PAGE_SIZE);
		     addr + PAGE_SIZE <= end; addr += PAGE_SIZE) {
			uint64_t page_index = addr >> 12;
			bitmap[page_index >> 3] &= ~(1 << (page_index & 7));
		}
	}

	// Reserve Kernel Image
	uint64_t kstart_page = (uintptr_t)_kernel_start >> 12;
	uint64_t kend_page = ((uintptr_t)_kernel_end + PAGE_SIZE - 1) >> 12;

	for (uint64_t page = kstart_page; page < kend_page; page++) {
		if ((page >> 3) < bitmap_bytes) {
			bitmap[page >> 3] |= (uint8_t)(1 << (page & 7));
		}
	}

	uint64_t bitmap_start_page = bitmap_addr >> 12;
	uint64_t bitmap_end_page =
		(bitmap_addr + bitmap_bytes + PAGE_SIZE - 1) >> 12;

	// Reserve Bitmap Memory
	for (uint64_t page = bitmap_start_page; page < bitmap_end_page;
	     page++) {
		bitmap[page >> 3] |= (1 << (page & 7));
	}

	// Reserve Low Memory (0x0 to 1MiB)
	for (uint64_t page = 0; page < (0x100000 >> 12); page++) {
		bitmap[page >> 3] |= (1 << (page & 7));
	}
}

void *pmm_alloc_page(void)
{
	for (uint64_t byte = next_free_byte; byte < bitmap_bytes; byte++) {
		if (bitmap[byte] == 0xFF)
			continue;

		for (uint8_t bit = 0; bit < 8; bit++) {
			if (bitmap[byte] & (1 << bit)) {
				continue;
			}

			bitmap[byte] |= (uint8_t)(1 << bit);
			next_free_byte = byte;

			uint64_t page_index = byte * 8 + bit;
			return (void *)(uintptr_t)(page_index << 12);
		}
	}

	for (uint64_t byte = 0; byte < next_free_byte; byte++) {
		if (bitmap[byte] == 0xFF)
			continue;

		for (uint8_t bit = 0; bit < 8; bit++) {
			if (bitmap[byte] & (1 << bit)) {
				continue;
			}

			bitmap[byte] |= (uint8_t)(1 << bit);
			next_free_byte = byte;

			uint64_t page_index = byte * 8 + bit;
			return (void *)(uintptr_t)(page_index << 12);
		}
	}

	return NULL; // OOM (Out Of Memory)
}

void pmm_free_page(void *page)
{
	uintptr_t addr = (uintptr_t)page;

	if (addr & (PAGE_SIZE - 1))
		return;

	// Protect Low Memory (0x0 to 1MiB)
	if (addr < 0x100000) {
		return;
	}

	// Protect Kernel Memory
	if (addr < (uintptr_t)_kernel_end && addr >= (uintptr_t)_kernel_start) {
		return;
	}

	// Protect PMM Bitmap metadata
	uintptr_t bitmap_end = (uintptr_t)bitmap + bitmap_bytes;
	if (addr >= (uintptr_t)bitmap && addr < bitmap_end)
		return;

	uint64_t page_index = addr >> 12;

	if ((page_index >> 3) < bitmap_bytes) {
		bitmap[page_index >> 3] &= ~(1 << (page_index & 7));
	}
}
