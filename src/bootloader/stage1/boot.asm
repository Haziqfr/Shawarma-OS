org 0x7C00
bits 16

start: 
  jmp main

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
  ; setup data segement
  mov ax, 0     ; we can't write directly to data segement
  mov ds, ax
  mov es, ax

  ; setup stack
  mov ss, ax
  mov sp, 0x7C00 ; stack grows downward

  mov [boot_drive], dl
  sti


  mov si, msg
  call puts

  jmp read
read:

  mov ax, 0x0000  ; segement
  mov es, ax
  mov ah, 0x02    ; bios function: read sector
  mov al, 1       ; read sector 1
  mov ch, 0
  mov cl, 2
  mov dl, [boot_drive]    ; Drive = first floppy
  mov dh, 0       ; head number
  mov bx, 0x7E00
  int 13h
  jc error

;  cmp ah, 0x0000
;  je error

  jmp 0x0000:0x7E00



.halt:
  jmp .halt


error:

  mov si, err_msg
  call puts

boot_drive: db 0
err_msg: db "Not found", 0x0D, 0x0A, 0
msg: db "Booting...", 0x0D, 0x0A, 0


times 510-($-$$) db 0
dw 0xAA55
