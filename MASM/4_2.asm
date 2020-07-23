mov ax, 0xb800
mov ds, ax
mov [0x00], 'a'
mov [0x02], 's'
mov [0x04], 'm'
jmp $
