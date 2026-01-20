ASM ?= nasm
CC ?= gcc
LD ?= ld

.PHONY: clean

$(BUILD_DIR)/stage2.bin:
	$(ASM) -f bin -o $(BUILD_DIR)/stage2.bin main.asm



clean:
	rm -rf $(BUILD_DIR)/stage2.bin
