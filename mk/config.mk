#
# Tools/Config
#

AS := nasm
CC := i686-elf-gcc
LD := i686-elf-gcc    # using gcc as linker driver
DD := dd
OBJCOPY := objcopy

ASFLAGS := -f bin
WARNFLAGS := -Wall -Wextra -Werror=strict-prototypes \
	-Wold-style-definition -Wundef -Wwrite-strings -Wpointer-arith
CFLAGS := -g -O0 -ffreestanding -fno-builtin -fno-pie \
	-fno-stack-protector -mno-mmx -mno-sse -nostdlib \
	-nostdinc -I include/ -c
CFLAGS +=
ASFLAGS_ELF := -f elf32


#
# Build folders
#

BUILD_DIR := build
SRC := src
BOOTLOADER_DIR := src/bootloader
STAGE1_ASM_SRC := $(wildcard $(BOOTLOADER_DIR)/stage1/*.asm)
STAGE1_5_ASM_SRC := $(wildcard $(BOOTLOADER_DIR)/stage1.5/*.asm)
KERNEL_ASM_SRC := $(shell find $(SRC)/kernel/ -type f -name "*.asm")
KERNEL_C_SRC := $(shell find $(SRC)/kernel/ -type f -name "*.c")
BOOTLOADER_BINS := $(BUILD_DIR)/stage1.bin $(BUILD_DIR)/stage1-5.bin
KERNEL_C_OBJS := $(patsubst $(SRC)/kernel/%.c, $(BUILD_DIR)/kernel/c/%.o, $(KERNEL_C_SRC))
KERNEL_ASM_OBJS := $(patsubst $(SRC)/kernel/%.asm, $(BUILD_DIR)/kernel/asm/%.o, $(KERNEL_ASM_SRC))
KERNEL_OBJS := $(KERNEL_C_OBJS) $(KERNEL_ASM_OBJS)

#
# Macro
#

#
# orchestration
#

.PHONY: clean all kernel run debug always floppy_image

.DELETE_ON_ERROR:

.DEFAULT_GOAL := all
