org    07c00h            　　　　; tell thecompiler that the program is loaded at 7c00
mov   ax, cs
mov   ds, ax
mov   es, ax
call   DispStr          　　　　; callthe example about string display
jmp   $            　　　　　　; unlimited loop
DispStr:
mov   ax, BootMessage
mov   bp, ax            　　　　; ES:BP =address of string
mov   cx, 16            　　　　; CX =length of string
mov   ax, 01301h        　　　　; AH =13, AL = 01h
mov   bx, 000ch       　　　　; page num = 0 (BH= 0), red word with black backgroud (BL = 0ch, highlight)
mov    dl, 0
int   10h            　　　　　　; breakat 10h
ret
BootMessage:           db     "Hello, OS World!"
times   510-($-$$)     db     0   ; fill the remaining space to the number of the binary code reach 512bytes
dw    0xaa55                　　　　 ; end