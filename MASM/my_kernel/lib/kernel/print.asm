T1_GDT equ 0
RPL0 equ 0
SELECTOR_VIDEO equ(0x0003 << 3) + T1_GDT + RPL0

[bits 32]
section .text

global put_char

;----------------put_char----------------
;功能描述:把栈中的1个字符写入光标所在处
;----------------------------------------
put_char:
    pushad                   ;备份32位寄存器环境
    mov ax, SELECTOR_VIDEO   
    mov gs, ax

    ;获取当前光标位置
    mov dx, 0x03d4           ;索引寄存器
    mov al, 0x0e             ;用于提供光标位置的高8位
    out dx, al
    mov dx, 0x03d5           ;通过读写数据端口0x3d5来获得或设置光标位置
    in al, dx
    mov ah, al
    
    ;获取低8位
    mov dx, 0x03d4
    mov al, 0x0f
    out dx, al
    mov dx, 0x03d5
    in al, dx

    ;将光标存入bx
    mov bx, ax
    ;在栈中获取待打印的字符
    mov ecx, [esp + 36]      ;pushad压入4*8=32字节
                             ;加上主调函数4字节的返回地址, 故esp+36字节
    
    ;判断参数是什么字符
    cmp cl, 0xd              ;回车符CR是0x0d, 换行符LF是0x0a
    jz .is_carrisge_return 
    cmp cl, 0xa
    jz .is_line_feed

    cmp cl, 0x8              ;退格键0x8
    jz .is_backspace 
    jmp .put_other

.is_backspace:
    dec bx
    shl bx, 1                ;光标左移一位等于乘2

    mov byte [gs:bx], 0x20
    inc bx
    mov byte [gs:bx], 0x7
    shr bx, 1
    jmp .set_cursor

.put_other:
    shl bx, 1

    mov [gs:bx], cl
    inc bx
    mov byte [gs:bx], 0x7
    shr bx, 1
    inc bx
    cmp bx, 2000
    jl .set_cursor

.is_line_feed:
.is_carrisge_return:
    xor dx, dx
    mov ax, bx
    mov si, 80

    div si

    sub bx, dx

.is_carrisge_return_end:
    add bx, 80
    cmp bx, 2000

.is_line_feed_end:
    jl .set_cursor

.roll_screen:
    cld
    mov ecx, 960
    mov esi, 0xc00b80a0
    mov edi, 0xc00b8000
    rep movsd

    mov ebx, 3840
    mov ecx, 80

.cls:
    mov word[gs:ebx], 0x0720
    add ebx, 2
    loop .cls
    mov bx, 1920

.set_cursor:
    mov dx, 0x03d4
    mov al, 0x0e
    out dx, al
    mov dx, 0x03d5
    mov al, bh
    out dx, al

    mov dx, 0x03d4
    mov al, 0x0f
    out dx, al
    mov dx, 0x03d5
    mov al, bl
    out dx, al

.put_char_done:
    popad
    ret
