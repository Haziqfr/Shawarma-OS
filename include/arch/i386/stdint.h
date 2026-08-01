#ifndef ARCH_I386_STDINT_H
#define ARCH_I386_STDINT_H

// Types
// Unsigned Integer 8-64 bit

typedef unsigned char uint8_t; // 8-bit unsigned integer
typedef unsigned short uint16_t; // 16-bit
typedef unsigned long int uint32_t; // 32-bit
typedef unsigned long long int uint64_t; // 64-bit

// Signed Integer 8-64 bit
typedef signed char int8_t; // 8-bit signed integer
typedef signed short int16_t; // 16-bit
typedef signed long int int32_t; // 32-bit
typedef signed long long int int64_t; // 64-bit

typedef uint32_t uintptr_t; // 32-bit pointer address width

// Macro Constants

// Signed Integers: minimum value
#define INT8_MIN (-128)
#define INT16_MIN (-32768)
#define INT32_MIN (-2147483647 - 1)
#define INT64_MIN (-9223372036854775807LL - 1LL)

// Signed Integers: maximum value
#define INT8_MAX 127
#define INT16_MAX 32767
#define INT32_MAX 2147483647
#define INT64_MAX 9223372036854775807LL

// Unsigned Integers: minimum value
#define UINT8_MIN 0
#define UINT16_MIN 0
#define UINT32_MIN 0U
#define UINT64_MIN 0ULL

// Unsigned Integers: maximum value
#define UINT8_MAX 255
#define UINT16_MAX 65535
#define UINT32_MAX 4294967295U
#define UINT64_MAX 18446744073709551615ULL


#endif /* ARCH_I386_STDINT_H */
