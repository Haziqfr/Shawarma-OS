#
# Builds Kernel
#
kernel: $(BUILD_DIR)/kernel.bin


$(BUILD_DIR)/kernel.bin: $(KERNEL_OBJS) src/kernel/linker.ld | always
	@$(LD) -nostdlib -T src/kernel/linker.ld -o $(BUILD_DIR)/kernel.elf $(KERNEL_OBJS)
	@$(OBJCOPY) -O binary $(BUILD_DIR)/kernel.elf $@


$(BUILD_DIR)/kernel/c/%.o: $(SRC)/kernel/%.c | always
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) $< -o $@

$(BUILD_DIR)/kernel/asm/%.o: $(SRC)/kernel/%.asm | always
	@mkdir -p $(dir $@)
	@$(AS) $(ASFLAGS_ELF) $< -o $@
