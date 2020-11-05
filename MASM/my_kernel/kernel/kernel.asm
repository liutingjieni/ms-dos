[bits 32]
;若在相关异常中CPU已经自动压入了错误码, 为保持栈中格式统一,这里不做操作
%define ERROR_CODE nop  

;若在相关异常中CPU没有压入错误码,为了统一栈中格式,就手工压入一个0
%define ZERO push 0

extern put_str;

section .data
intr_str  db "interrupt occur!", 0xa, 0

global intr_entry_table
intr_entry_table:

%macro VECTOR 2
section .text
intr%1entry:
    %2 
    push intr_str
    call put_str
    add esp, 4

    mov al, 0x20
    out 0xa0, al
    out 0x20, al

    add esp, 4
    iret

section .data:
    dd intr%1entry
%endmacro

VECTOR 0x00, ZERO
VECTOR 0x01, ZERO
VECTOR 0x02, ZERO

VECTOR 0x1e, ERROR_CODE
VECTOR 0x1f, ZERO
VECTOR 0x20, ZERO
