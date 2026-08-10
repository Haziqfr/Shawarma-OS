#
# Floppy image dependency
#

floppy_image: $(BUILD_DIR)/main_floppy.img


#
# Creates floppy image
#

$(BUILD_DIR)/main_floppy.img: $(BOOTLOADER_BINS) $(BUILD_DIR)/kernel.bin | always
	@$(DD) if=/dev/zero of=$@ bs=512 count=2880 status=none
	@$(DD) if=$(BUILD_DIR)/stage1.bin of=$@ conv=notrunc
	@$(DD) if=$(BUILD_DIR)/stage1-5.bin of=$@ seek=1 conv=notrunc bs=512
	@$(DD) if=$(BUILD_DIR)/kernel.bin of=$@ seek=3 conv=notrunc bs=512


#	cp $(BUILD_DIR)/stage1.bin $(BUILD_DIR)/main_floppy.img
#	truncate -s 1440k $(BUILD_DIR)/main_floppy.img
