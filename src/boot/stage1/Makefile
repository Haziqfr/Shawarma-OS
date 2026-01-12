ASM ?= nasm
CC ?= gcc

BUILD_DIR ?= build/



.PHONY: all clean

stage1: $(BUILD_DIR)/stage1.bin

$(BUILD_DIR)/stage1.bin:
	$(ASM) -o $(BUILD_DIR)/stage1.bin -f bin boot.asm


clean:
	rm -rf $(BUILD_DIR)/stage1.bin
