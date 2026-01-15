global puts
;global _start

puts:
  mov rsi, rdi

.loop: 
  mov al, [rsi]
  or al, al
  jz .done
    

  mov rax, 1
  mov rdi, 1
  mov rdx, 1
  syscall

  inc rsi

  jmp .loop

.done:
  

  mov rax, 1
  mov rdx, 1
  mov rdi, 1
  mov rsi, nl
  syscall
  ret


nl: db 0x0A


;_start:
;  mov rsi, msg 
;  call put_my_ass

;  mov rax, 60
;  xor rdi, rdi
;  syscall

;msg: db "Hello", 0
