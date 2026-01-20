ORG 0x7C00
bits 16

main:
  mov ax, 0x0000
  mov es, ax
  mov ah, 0x02
  mov al, 1
  mov ch, 0
  mov cl, 1
  mov dh, 0
  mov dl, 0x00
  mov bx, 0x7E00
  int 0x13


times 510-($-$$) db 0
dw 0xAA55
