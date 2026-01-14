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
  sti

  mov si, msg
  call puts

  hlt  



.halt:
  jmp .halt

msg: db "Booting...", 0


times 510-($-$$) db 0
dw 0xAA55
