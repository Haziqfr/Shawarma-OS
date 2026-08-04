#ifndef SHAWARMAOS_STRING_H
#define SHAWARMAOS_STRING_H

// Includes
#include <stddef.h>

// Function Prototypes: memory manipulation
void *memcpy(void *dest, const void *src, size_t count);
void *memset(void *dest, int value, size_t count);
int memcmp(const void *lhs, const void *rhs, size_t count);
void *memmove(void *dest, const void *src, size_t count);


#endif /* SHAWARMAOS_STRING_H */
