section .bss
resb 2*32

section .data

strHello db "helloworld!",0ah
STRLEN equ $-strHello

section .data
extern print

global _start
_start:
    push STRLEN
    push strHello
    call print

    mov ebx, 0
    mov eax, 1
    int 0x80
