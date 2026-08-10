[ORG 0x7E00]
[BITS 16]


; magic  dw 0xBEEF
; version dw 1

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
  lgdt [gdt_descriptor]    ; load gdt table address to GDTR
  mov eax, cr0
  or  eax, 1               
  mov cr0, eax             ; enable Protected Mode
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

msg: db "I am stage1.5, I am alive", 0x0D, 0x0A, 0

times 1024-($-$$) db 0
