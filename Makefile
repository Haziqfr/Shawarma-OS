#
# Tools/Config
#

ASM = nasm
CC = gcc

#
# Build folders
#

BUILD_DIR	=	build/
SRC	=	src/
#
# orchestration
#

.PHONY: clean all kernel boot run always 

boot: stage1 stage2

stage1: $(BUILD_DIR)/stage1.bin

$(BUILD_DIR)/stage1.bin: always
	$(MAKE) -C $(SRC)/boot/stage1 BUILD_DIR=$(abspath $(BUILD_DIR))


always:
	mkdir -p $(BUILD_DIR)

clean: 
	rm -rf $(BUILD_DIR)/*
