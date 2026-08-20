[ORG 0x7E00]
[BITS 16]

; Macro to assert compile-time conditions
%macro static_assert 2
    %if !( %1 )
        %fatal %2
    %endif
%endmacro


BOOTINFO_ADDR      equ 0x6D00
MMAP_MAX_ENTRIES   equ 128
MMAP_ENTRY_SIZE    equ 20
VBE_INFO_ADDR_SEG  equ 0x7000
VBE_MODEINFO_ADDR_SEG equ 0x7100

MAGIC              equ 0x88FF1A3B ; crc32("ShawarmaOS Boot Protocol")

CODE_SEG equ code_segment_descriptor - gdt_start    ; code segment pointer
DATA_SEG equ data_segment_descriptor - gdt_start    ; data segment pointer
        ; equ is used to set constants in NASM


; entry_headers:
;  dw main ; location of main / offset
;  dw 0    ; segment



main:
  mov [lba_status], al
  mov [boot_drive], dl
  xor ax, ax    ; clear ax
  mov ds, ax    ; set data segment
  mov es, ax    ; keep es synchronize with ds

  
  mov si, msg   ; load message
  call puts     ; call print function


  call get_a20_state

  cmp ax, 0
  jne .continue    ; continue if already enabled


  call enable_a20


  call get_a20_state
  cmp ax, 0    
  je .halt    ; halt if A20 can't be enabled


.continue:
 ; Magic = crc-32("ShawarmaOS Boot Protocol")
 mov dword [BOOTINFO_ADDR + BootInfo.magic], MAGIC
 mov word [BOOTINFO_ADDR + BootInfo.version], 0x0200
 call get_memory_map
 call get_vbe_info
 call get_vbe_mode_info
 mov al, [lba_status]
 cmp al, 2
 je .lba_read


.chs_read:
 xor ax, ax
 mov es, ax
 mov ax, 0x0238
 mov cx, 0x0004
 mov dh, 0
 mov dl, [boot_drive]
 mov bx, 0x9000
 int 0x13
 jc .halt
 jnc .stage_finale

.lba_read:
    xor ax, ax
    mov ds, ax
    mov si, DAP
    mov dl, [boot_drive]
    mov ah, 0x42
    int 13h

.stage_finale:
  cli                      ; disable all interrupts
  push 0
  pop ds
  lgdt [gdt_descriptor]    ; load gdt table address to GDTR
  mov eax, cr0
  or  eax, 1               
  mov cr0, eax             ; enable Protected Mode
  mov ebx, BOOTINFO_ADDR
  jmp CODE_SEG:0x9000    ; flush prefetched instructions and jump to protected mode start

  jmp .halt


.halt:
  cli
  hlt
  jmp .halt


;	out:
;		ax - state (0 - disabled, 1 - enabled)
get_a20_state:
	pushf                      ; push all flags
	push si
	push di
	push ds
	push es
	cli

	mov ax, 0x0000             ; 0x0000:0x0500(0x00000500) -> ds:si
	mov ds, ax
	mov si, 0x0500

	not ax                     ; 0xffff:0x0510(0x00100500) -> es:di
	mov es, ax
	mov di, 0x0510

	mov al, [ds:si]            ; save old values
	mov byte [.BufferBelowMB], al
	mov al, [es:di]
	mov byte [.BufferOverMB], al

	mov ah, 1
	mov byte [ds:si], 0
	mov byte [es:di], 1
	mov al, [ds:si]
	cmp al, [es:di]            ; check byte at address 0x0500 != byte at address 0x100500
	jne .exit
	dec ah
.exit:
	mov al, [.BufferBelowMB]
	mov [ds:si], al
	mov al, [.BufferOverMB]
	mov [es:di], al
	shr ax, 8                  ; move result from ah to al register and clear ah
	pop es
	pop ds
	pop di
	pop si
	popf                       ; pop all flags
	ret

.BufferBelowMB:	db 0
.BufferOverMB:	db 0




enable_a20:

.bios_int:   ; Try to enable A20 via BIOS interrupts

    mov ax, 0x2401     ; try to enable A20 gate however bios likes
    int 0x15

    jc .fast           ; jump to fast gate method if bios A20 gate not supported
    cmp ah, 0
    jne .fast          ; try fast gate if any errors
    

    call get_a20_state

    cmp ax, 1
    jne .fast

    ret                ; return if succeed



.fast:         ; try to enable A20 via fast gate

    in al, 0x92           ; take input from port 0x92
    or al, 00000010b      ; enable A20
    and al, 11111110b     ; keep cpu from resetting(reboot)
    out 0x92, al          ; write output to port 0x92

    call get_a20_state

    cmp ax, 1
    jne .keyboard         ; jump to keyboard method if fast20 failed

    ret                   ; return if succeed          


.keyboard:      ; try to enable A20 via keyboard controller

pushf                   ; save all flags
cli                     ; disable interrupts

call    .a20wait
mov     al,0xAD
out     0x64,al         ; disable keyboard

call    .a20wait
mov     al,0xD0
out     0x64,al         ; read controller output port

call    .a20wait2
in      al,0x60         ; save response byte
push    ax

call    .a20wait
mov     al,0xD1
out     0x64,al         ; write next byte into controller output port

call    .a20wait
pop     ax
or      al,2            ; set controller output bit for A20 on
out     0x60,al         ; activate A20

call    .a20wait
mov     al,0xAE
out     0x64,al         ; reactivate keyboard

call    .a20wait

popf                    ; pop all flags
ret

.a20wait:               ; wait until input buffer is clear
in      al,0x64
test    al,2
jnz     .a20wait
ret


.a20wait2:                       ; wait until response byte has arrived
in      al,0x64
test    al,1
jz     .a20wait2
ret



get_memory_map:

    xor bx, bx
    xor ax, ax
    mov es, ax
    mov di, (BOOTINFO_ADDR + BootInfo.e820_table)
    mov byte [BOOTINFO_ADDR + BootInfo.e820_entries], 0

.next:
    mov eax, 0xE820
    mov edx, 0x534D4150 ; 'SMAP' in little endian
    mov ecx, MMAP_ENTRY_SIZE

    int 0x15

    jc .fail
    cmp eax, 0x534D4150
    jne .fail
    cmp ecx, MMAP_ENTRY_SIZE
    jb .fail

    cmp byte [BOOTINFO_ADDR + BootInfo.e820_entries], MMAP_MAX_ENTRIES
    jae .fail

    inc byte [BOOTINFO_ADDR + BootInfo.e820_entries]


    add di, MMAP_ENTRY_SIZE

    cmp ebx, 0
    je .success

    jne .next


.fail:
    mov si, err_mm_failed_msg
    call puts
.halt:
    cli
    hlt
    jmp .halt

.success:
    ret

get_vbe_info:
    xor ax, ax
    mov ax, VBE_INFO_ADDR_SEG
    mov es, ax
    xor di, di

    mov dword [es:di + VbeInfo.signature], 'VBE2'

    ; ah = 4Fh - VBE function, al = 00h - Get SuperVGA Info
    mov ax, 0x4F00
    int 0x10

    cmp ax, 0x004F
    jne .fail

    ret

.fail:
    mov si, err_framebuff_failed_msg
    call puts
.halt:
    cli
    hlt
    jmp .halt

;
; Preferably we want the highest resolution and 32bit Bit Per Pixel
; with Linear Frame Buffer
;

get_vbe_mode_info:
    push VBE_INFO_ADDR_SEG
    pop ds
    lds si, [VbeInfo.video_mode_ptr]

    ; Load the SuperVGA mode info buffer at es:di
    push VBE_MODEINFO_ADDR_SEG
    pop es
    xor di, di

    cld ; ensure DF = 0 so LODSW increments SI

.next_mode:
    lodsw ; Loads the mode number from ds:si to AX then increments si by 2
    cmp ax, 0xFFFF
    je .done

    push si
    push ax ; preserve mode number

    xchg ax, cx ; exchange the contents of AX to CX and vice versa
    mov ax, 0x4F01
    int 0x10

    ;jc .skip_mode
    cmp ax, 0x004F
    jne .skip_mode

    mov ax, [es:ModeInfo.mode_attrib]
    and ax, 0x0090 ; we only care about bit4 (graphics mode) and bit7 (lfb support)
    cmp ax, 0x0090
    jne .skip_mode

    mov bl, byte [es:ModeInfo.depth]
    cmp bl, 24 ; only support 24+ bpp/depth
    jb .skip_mode

    movzx eax, word [es:ModeInfo.x_resolution]
    movzx ecx, word [es:ModeInfo.y_resolution]
    mul ecx

    movzx ecx, bl
    imul ecx, ecx, 10000000
    add eax, ecx

    cmp eax, [cs:best_vbe_mode_score]
    jbe .skip_mode

    mov dword [cs:best_vbe_mode_score], eax
    pop ax
    push ax
    mov word [cs:best_vbe_mode], ax

.skip_mode:
    pop ax
    pop si
    jmp .next_mode

.done:
    cmp dword [cs:best_vbe_mode_score], 0
    je .fail

    ; load the best mode buff
    push VBE_MODEINFO_ADDR_SEG
    pop es
    xor di, di
    mov cx, word [cs:best_vbe_mode]
    mov ax, 0x4F01
    int 0x10

.finale:
    push 0
    pop gs

    mov eax, dword [es:ModeInfo.phys_base_ptr]
    mov dword [gs:BOOTINFO_ADDR + BootInfo.screen_info + screen_info.lfb_base], eax

    mov eax, dword [es:ModeInfo.x_resolution]
    mov dword [gs:BOOTINFO_ADDR + BootInfo.screen_info + screen_info.lfb_width], eax

    mov ax, [es:ModeInfo.bytes_per_scan_line]
    mov word [gs:BOOTINFO_ADDR + BootInfo.screen_info + screen_info.lfb_pitch], ax

    mov al, [es:ModeInfo.depth]
    mov byte [gs:BOOTINFO_ADDR + BootInfo.screen_info + screen_info.lfb_depth], al

    mov ax, word [es:ModeInfo.red_size]
    mov byte [gs:BOOTINFO_ADDR + BootInfo.screen_info + screen_info.red_pos], ah
    mov byte [gs:BOOTINFO_ADDR + BootInfo.screen_info + screen_info.red_size], al

    mov ax, word [es:ModeInfo.green_size]
    mov byte [gs:BOOTINFO_ADDR + BootInfo.screen_info + screen_info.green_pos], ah
    mov byte [gs:BOOTINFO_ADDR + BootInfo.screen_info + screen_info.green_size], al

    mov ax, word [es:ModeInfo.blue_size]
    mov byte [gs:BOOTINFO_ADDR + BootInfo.screen_info + screen_info.blue_pos], ah
    mov byte [gs:BOOTINFO_ADDR + BootInfo.screen_info + screen_info.blue_size], al

    mov ax, word [es:ModeInfo.reserved_size]
    mov byte [gs:BOOTINFO_ADDR + BootInfo.screen_info + screen_info.reserved_pos], ah
    mov byte [gs:BOOTINFO_ADDR + BootInfo.screen_info + screen_info.reserved_size], al

    ret

.fail:
    mov si, err_mode_failed_msg
    call puts
.halt:
    cli
    hlt
    jmp .halt


puts:
 push si
 push ax

 .loop:
 lodsb         ; loads next char from DS:SI into AL
 or al, al     ; check for null terminator
 jz .done      ; jump to .done if encountered null terminator

 mov ah, 0x0E ; BIOS teletype print
 int 0x10     ; Video service interrupt

 jmp .loop    ; repeat until null terminator

 .done:

 pop ax
 pop si

 ret


gdt_start:

null_descriptor:
    dd 0
    dd 0

code_segment_descriptor:
    dw 0xFFFF        ; Limit (0-15)
    dw 0x0000        ; Base (0-15)
    db 0x00          ; Base (16-23)
    db 10011010b     ; Access Byte (0-7): P=1, DPL=00, S=1, E=1, DC=0(Non-Conforming), RW=1(Read true), A=0
    db 11001111b     ; Flags (0-3)(upper 4 bit) G=1, DB=1, L=not applicable, AVL=0(IDK why) | Limit (16-19) (lower 4 bit)
    db 0x00          ; Base (24-31)


data_segment_descriptor:
    dw 0xFFFF        ; Limit (0-15)
    dw 0x0000        ; Base (0-15)
    db 0x00          ; Base (16-23)
    db 10010010b     ; Access Byte (0-7): P=1, DPL=00, S=1, E=0, DC=0(Direction Up), RW=1(Write true), A=0
    db 11001111b     ; Flags (0-3)(upper 4 bit): G=1, DB=1, L=not applicable, AVL=0(IDK why) | Limit (16-19) (lower 4 bit)
    db 0x00          ; Base (24-31)


gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start -1
    dd gdt_start



; DATA
DAP:
    db 0x10      ; size of DAP, 16 bytes
    db 0x00      ; reserved, always 0
    dw 0x0038    ; sectors to read
    dw 0x9000, 0x0000        ; loading address
    dq 0x0000000000000003    ; sector number


boot_drive: db 0
lba_status: db 0

best_vbe_mode: dw 0
best_vbe_mode_score: dd 0

struc screen_info
    .lfb_base:   resb 8  ; 0x00
    .lfb_size:   resb 8  ; 0x08

    .lfb_width:  resb 2  ; 0x10
    .lfb_height: resb 2  ; 0x12
    .lfb_pitch:  resb 2  ; 0x14
    .lfb_depth:  resb 1  ; 0x16

    .red_pos:    resb 1  ; 0x17
    .red_size:   resb 1  ; 0x18

    .green_pos:  resb 1  ; 0x19
    .green_size: resb 1  ; 0x1A

    .blue_pos:   resb 1  ; 0x1B
    .blue_size:  resb 1  ; 0x1C

    .reserved_pos:  resb 1  ; 0x1D
    .reserved_size: resb 1  ; 0x1E

    .reserved:   resb 33 ; 0x1F

endstruc

%assign ScreenInfoSize screen_info_size
static_assert (ScreenInfoSize == 64), CRITICAL: ScreenInfo must be 64 bytes. Current size: %[ScreenInfoSize] bytes

struc BootInfo
    .magic:         resb 4     ; 0x000
    .version:       resb 2     ; 0x004

    .e820_entries:  resb 1     ; 0x006
    .reserved0:     resb 1     ; 0x007
    .e820_table:    resb 2560  ; 0x008
    .screen_info:   resb screen_info_size ; 0xA08

    .reserved1:     resb 1464  ; 0xA48

endstruc

%assign BootInfoSize BootInfo_size
static_assert (BootInfoSize == 4096), CRITICAL: BootInfo must be 4096 bytes. Current size: %[BootInfoSize] bytes

struc VbeInfo
    .signature:            resb 4   ; 0x000
    .version:              resb 2   ; 0x004
    .oem_string_ptr:       resb 4   ; 0x006
    .capabilities:         resb 4   ; 0x00A
    .video_mode_ptr:       resb 4   ; 0x00E
    .total_mem:            resb 2   ; 0x012

    ; OEM metadata - irrelevant to us for now
    .oem_sftwr_rev:        resb 2   ; 0x014
    .oem_vendor_name_ptr:  resb 4   ; 0x016
    .oem_product_name_ptr: resb 4   ; 0x01A
    .oem_product_rev_ptr:  resb 4   ; 0x01E
    .reserved:             resb 222 ; 0x022
    .oem_data:             resb 256 ; 0x100
endstruc

%assign VbeInfoSize VbeInfo_size
static_assert (VbeInfoSize == 512), CRITICAL: VbeInfo must be 512 bytes. Current size: %[VbeInfoSize] bytes

struc ModeInfo
    ; Available for all VBE rev
    .mode_attrib:     resb 2       ; 0x00
    .winA_atrib:     resb 1       ; 0x02
    .winB_atrib:     resb 1       ; 0x03
    .win_granuality: resb 2       ; 0x04
    .win_size:       resb 2       ; 0x06
    .winA_seg:       resb 2       ; 0x08
    .winB_seg:       resb 2       ; 0x0A
    .win_func_ptr:   resb 4       ; 0x0C
    .bytes_per_scan_line: resb 2  ; 0x10

    ; Available for VBE 1.2+
    .x_resolution: resb 2         ; 0x12
    .y_resolution: resb 2         ; 0x14
    .x_char_size:  resb 1         ; 0x16
    .y_char_size:  resb 1         ; 0x17
    .mem_plane_count: resb 1      ; 0x18
    .depth:        resb 1         ; 0x19
    .bank_count:   resb 1         ; 0x1A
    .mem_model:    resb 1         ; 0x1B
    .bank_size:    resb 1         ; 0x1C
    .img_page_count: resb 1       ; 0x1D
    ._reserved0:   resb 1         ; 0x1E

    ; Direct Color fields
    .red_size:   resb 1           ; 0x1F
    .red_pos:    resb 1           ; 0x20
    .green_size: resb 1           ; 0x21
    .green_pos:  resb 1           ; 0x22
    .blue_size:  resb 1           ; 0x23
    .blue_pos:   resb 1           ; 0x24
    .reserved_size: resb 1        ; 0x25
    .reserved_pos: resb 1         ; 0x26
    .direct_color_mode_info: resb 1 ; 0x27

    ; Available for VBE 2.0+
    .phys_base_ptr: resb 4        ; 0x28
    ._reserved1:    resb 6        ; 0x2C

    ; Available for VBE 3.0+
    .lin_bytes_scan_line: resb 2  ; 0x32
    .bank_img_page_count: resb 1  ; 0x34
    .lin_img_page_count:  resb 1  ; 0x35
    .lin_red_size:        resb 1  ; 0x36
    .lin_red_pos:         resb 1  ; 0x37
    .lin_green_size:      resb 1  ; 0x38
    .lin_green_pos:       resb 1  ; 0x39
    .lin_blue_size:       resb 1  ; 0x3A
    .lin_blue_pos:        resb 1  ; 0x3B
    .lin_rsvd_size:       resb 1  ; 0x3C
    .lin_rsvd_pos:        resb 1  ; 0x3D
    .max_pixel_clock:     resb 4  ; 0x3E

    ._reserved2: resb 190         ; 0x42

endstruc

%assign ModeInfoSize ModeInfo_size
static_assert (ModeInfoSize == 256), \
    CRITICAL: ModeInfo must be 256 bytes. Current size: %[ModeInfoSize] bytes

; Messages
msg: db "I am stage1.5, I am alive", 0x0D, 0x0A, 0

; Error messages
err_mm_failed_msg: db "Unable to detect Memory Map", 0x0D, 0x0A, "Halting...", 0x0D, 0x0A, 0
err_framebuff_failed_msg: db "Unable to get framebuffer", 0x0D, 0x0A, "Halting...", 0x0D, 0x0A, 0
err_mode_failed_msg: db "Unable to get suitable VBE mode", 0x0D, 0x0A, "Halting...", 0x0D, 0x0A, 0

times 1024-($-$$) db 0
