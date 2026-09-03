#ifndef MM_PMM_H
#define MM_PMM_H

// Includes
#include <uapi/genesis/bootparam.h>

// Macro Constants
#define PAGE_SIZE 4096 /* In bytes */
#define USABLE 1

void pmm_init(BootInfo *boot);
void *pmm_alloc_page(void);
void pmm_free_page(void *page);

#endif /* MM_PMM_H */
