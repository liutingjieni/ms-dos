
section loader vstart = LOADER_BASE_ADDR
LOADER_STACK_TOP equ LOADER_BASE_ADDR

total_mem_bytes dd 0

gdt_ptr dw GDT_LIMIT  ;gdt界限
        dd GDT_BASE   ;gdt起始地址


ards_buf times 244 db 0
ards_nr dw 0

loader_start:
    xor ebx, ebx
    mov edx, 0x534d4150
    mov di, ards_buf

.e820_mem_get_loop:
    mov eax, 0x0000e820
    mov ecx, 20
    int 0x15;
    jc .e820_failed_so_try_e801
    add di, cx
    inc word [ards_nr]
    cmp ebx, 0
    jnz .e820_mem_get_loop


    mov cx, [ards_nr]
    mov ebx, ards_buf
    xor edx, edx

.find_max_mem_area:
    mov eax, [ebx]
    add eax, [ebx + 8]
    add ebx, 20
    cmp edx, eax



    






