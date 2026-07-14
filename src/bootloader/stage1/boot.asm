org 0x7C00
bits 16

start:
  jmp 0:main


puts:
  push si
  push ax

.loop:
  lodsb       ; loads next char in al
  or al, al
  jz .done


  mov ah, 0x0E
  int 0x10

  jmp .loop

.done:
  pop ax
  pop si
  ret



main:


  cli
  cld    ; clear direction flag so loadsb behaves properly

  ; setup data segment
  xor ax, ax     ; we can't write directly to data segment
  mov ds, ax
  mov es, ax

  ; setup stack
  mov ss, ax
  mov sp, 0x9000 ; stack grows downward

  mov [boot_drive], dl    ; save boot drive
  sti


  mov si, msg_boot
  call puts

  mov al, [boot_drive]
  cmp al, 0x80
  jae .hard_drive


.floppy:
    call probe_floppy
    jmp chs_read
    


.hard_drive:
    call get_Hdisk_geometry
    
    call check_lba
    jc chs_read

    jmp lba_read

    jmp halt


probe_floppy:
  mov si, floppy_selectors

.probe_loop:

  push ax    ; save ax
  ; reset first
  mov ah, 0x00
  mov dl, [boot_drive]
  int 0x13
  pop ax

  mov cl, [si]
  or cl, cl
  jz error_nf_floppy


  mov ax, 0x0201
  mov ch, 0
  mov dh, 0
  mov dl, [boot_drive]

  push es
  xor bx, bx
  mov es, bx
  mov bx, 0x0600
  int 0x13
  pop es

  jnc .probe_success

  inc si
  jmp .probe_loop



.probe_success:
  xor ax, ax
  mov al, cl
  mov [sectors_per_track], ax
  ret


; out:
;     CF - state (0 - enabled, 1 - disabled)
check_lba:

    mov ah, 0x41
    mov bx, 0x55AA
    mov dl, [boot_drive]
    int 0x13

    jc .error_LBA

    cmp bx, 0xAA55
    jne .error_LBA

    test cx, 1
    jz .error_LBA

    mov si, msg_LBA
    call puts

    clc
    ret

.error_LBA:
   mov si, err_LBA_msg
   call puts

   stc
   ret

chs_read:

    mov si, 3

.retry:

  push si
  
  mov ax, 1
  call lba_to_chs

  mov ax, 0x0000    ; segment
  mov es, ax
  mov bx, 0x7E00
  
  mov ax, 0x0201    ; AH=02h, AL=01h
;  mov al, 1        ; read sector 1
;  mov cx, 0x0002    ; CH=0x00 (Cylinder 0), CL=0x02 (Sector 2)
;  mov cl, 2
  mov dl, [boot_drive]    ; Drive = first floppy
;  mov dh, 0         ; head number


  int 13h
  jnc .ok
  jc .fail


.fail:

  xor ax, ax
  mov dl, [boot_drive]
  int 0x13

  pop si
  dec si
  jnz .retry

  jmp error_nf_stage

.ok:

  pop si
  ; Validation before jump
  ;cmp word [0x7E00], 0xBEEF
  ;jne error
  mov al, 0x03    ; exit_code[3]
  mov dl, [boot_drive]
  jmp 0:0x7e00

  jmp halt

get_Hdisk_geometry:

    mov ah, 0x08
    mov dl, [boot_drive]
    int 0x13
    jc error_geo

    inc dh

    xor ax, ax
    mov al, dh
    mov [total_heads], ax

    xor ax, ax
    and cl, 00111111b
    mov al, cl
    mov [sectors_per_track], ax

    ret




lba_to_chs:
    push bx
    push ax                         ; Save original LBA

    xor dx, dx                      ; Clear DX for division (DX:AX)
    mov bx, [sectors_per_track]     ; Load your dynamically probed variable
    div bx                          ; AX = LBA / SPT, DX = LBA % SPT

    inc dx                          ; Sector = (LBA % SPT) + 1
    mov cl, dl                      ; CL = Sector number

    xor dx, dx                      ; Clear DX again
    xor bx, bx
    mov bl, [total_heads]           ; Number of heads for a standard floppy
    div bx                          ; AX = Cylinder (AX/2), DX = Head (AX%2)

    mov dh, dl                      ; DH = Head
    mov ch, al                      ; CH = Cylinder (lower 8 bits)

    ; Optional: If cylinder > 255, its high bits go into CL bits 6-7.
    ; For standard floppies, cylinder never exceeds 80, so CH is completely fine.

    pop ax
    pop bx
    ret



    

lba_read:
    xor ax, ax
    mov ds, ax
    mov si, DAP
    mov dl, [boot_drive]
    mov ah, 0x42
    int 13h

    jc error_nf_stage

.success:
    mov al, 0x02    ; 1 - LBA supported
    mov dl, [boot_drive]
    jmp 0:0x7E00



error_nf_floppy:

    mov si, err_NFF_msg
    call puts

    jmp halt

error_nf_stage:

    mov si, err_NFS_msg
    call puts

    jmp halt

error_geo:
    mov si, err_GEO_msg
    call puts

    jmp halt

halt:
   hlt
   jmp halt


; DATA
DAP:
    db 0x10      ; size of DAP, 16 bytes
    db 0x00      ; reserved, always 0
    dw 0x0001    ; sectors to read
    dw 0x7E00, 0x0000        ; loading address
    dq 0x0000000000000001    ; sector number


floppy_selectors: db 36, 18, 15, 9, 0
boot_drive: db 0

align 2
sectors_per_track: dw 0
total_heads: dw 2



; Strings
; errors_msg
err_NFF_msg: db "NFF", 0    ; Not Found Floppy
err_NFS_msg: db "NFS", 0    ; Not Found Stage
err_GEO_msg: db "Unable to get disk geo", 0
err_LBA_msg: db "LBA 3, Fallbacking to CHS", 0x0D, 0x0A, 0  ; exit code[3]

; msg
msg_boot: db "Booting...", 0x0D, 0x0A, 0
msg_LBA: db "LBA 2", 0x0D, 0x0A, 0    ; exit code[2]


times 510-($-$$) db 0
dw 0xAA55
