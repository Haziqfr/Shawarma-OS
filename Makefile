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
BOOTLOADER_DIR = src/bootloader/



#
# orchestration
#

.PHONY: clean all kernel bootloader run always floppy_image




#
# All
#

all: floppy_image




#
# Floppy image dependency
#

floppy_image: $(BUILD_DIR)/main_floppy.img


#
# Creates floppy image
#

$(BUILD_DIR)/main_floppy.img: stage1		#bootloader kernel
	cp $(BUILD_DIR)/stage1.bin $(BUILD_DIR)/main_floppy.img
	truncate -s 1440k $(BUILD_DIR)/main_floppy.img





#
# Bootloader Dependencies
#

bootloader: stage1 stage2





#
# Creates stage-1 bootloader
#

stage1: $(BUILD_DIR)/stage1.bin

$(BUILD_DIR)/stage1.bin: always
	$(MAKE) -C $(BOOTLOADER_DIR)/stage1 BUILD_DIR=$(abspath $(BUILD_DIR))





#
# Creates stage-2 bootloader
#

stage2: $(BUILD_DIR)/stage2.bin

$(BUILD_DIR)/stage2.bin:	always
	$(MAKE) -C $(BOOTLOADER_DIR)stage2 BUILD_DIR=$(abspath $(BUILD_DIR))







#
# Run
#
run: $(BUILD_DIR)/main_floppy.img
	qemu-system-i386 -fda $(BUILD_DIR)/main_floppy.img



#
# always runs
# 	- Creates BUILD_DIR if not created
#

always:
	mkdir -p $(BUILD_DIR)





#
# Removes everything from BUILD_DIR 
#

clean: 
	$(MAKE) -C $(BOOTLOADER_DIR)/stage1 BUILD_DIR=$(abspath $(BUILD_DIR)) clean
	rm -rf $(BUILD_DIR)/*
