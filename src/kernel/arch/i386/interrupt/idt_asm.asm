[bits 32]

global idt_load
extern interrupt_dispatch

idt_load:
    cli
    mov eax, [esp + 4]
    lidt [eax]
    ret

%macro ISR_NOERRCODE 1
global isr%1
isr%1:
    cli
    push byte 0
    push %1
    jmp isr_common_stub
%endmacro

%macro ISR_ERRCODE 1
global isr%1
isr%1:
    cli
    push %1
    jmp isr_common_stub
%endmacro

%assign i 0
%rep 256

    %if i == 8 || (i >= 10 && i <= 14) || i == 17 || i == 21
        ISR_ERRCODE i
    %else
        ISR_NOERRCODE i
    %endif

    %assign i i+1
%endrep

isr_common_stub:
    pusha

    mov ax, ds
    push eax

    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    push esp
    call interrupt_dispatch
    add esp, 4

    pop eax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    popa
    add esp, 8
    sti
    iret

global isr_stub_table
isr_stub_table:
%assign i 0
%rep 256
    dd isr%+i
    %assign i i+1
%endrep
