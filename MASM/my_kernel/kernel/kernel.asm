[bits 32]
;若在相关异常中CPU已经自动压入了错误码, 为保持栈中格式统一,这里不做操作
%define ERROR_CODE nop  

;若在相关异常中CPU没有压入错误码,为了统一栈中格式,就手工压入一个0
%define ZERO push 0

extern put_str;
extern idt_table

section .data
intr_str  db "interrupt occur!", 0xa, 0

global intr_entry_table
intr_entry_table:

%macro VECTOR 2
section .text
intr%1entry:
    %2
    push ds
    push es
    push fs
    push gs
    pushad

    mov al, 0x20
    out 0xa0, al
    out 0x20, al

    push %1
    
    push intr_str
    call put_str
    add esp, 4

    call [idt_table + %1 * 4]
    jmp intr_exit

section .data:
    dd intr%1entry
%endmacro

section .text
global intr_exit

intr_exit:
add esp, 4
popad
pop gs
pop fs
pop es
pop ds
add esp, 4
iretd


//VECTOR 0x00, ZERO
VECTOR 0x01, ZERO
VECTOR 0x02, ZERO
VECTOR 0x03, ZERO
VECTOR 0x04, ZERO
VECTOR 0x05, ZERO
VECTOR 0x06, ZERO
VECTOR 0x07, ZERO
VECTOR 0x08, ZERO
VECTOR 0x09, ZERO
VECTOR 0x0a, ZERO
VECTOR 0x0b, ZERO
VECTOR 0x0c, ZERO
VECTOR 0x0d, ZERO
VECTOR 0x0e, ZERO
VECTOR 0x0f, ZERO
VECTOR 0x10, ZERO
VECTOR 0x11, ZERO
VECTOR 0x12, ZERO
VECTOR 0x13, ZERO
VECTOR 0x14, ZERO
VECTOR 0x15, ZERO
VECTOR 0x16, ZERO
VECTOR 0x17, ZERO
VECTOR 0x18, ZERO
VECTOR 0x19, ZERO
VECTOR 0x1a, ZERO
VECTOR 0x1b, ZERO
VECTOR 0x1c, ZERO
VECTOR 0x1d, ZERO
VECTOR 0x1e, ERROR_CODE
VECTOR 0x1f, ZERO
VECTOR 0x20, ZERO
