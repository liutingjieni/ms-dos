_stack segment stack 'stack';	定义堆栈段
	db 32766 dup(0)	;堆栈区长度:32766+2=32KB
	tos dw 0	;定义堆栈栈顶
_stack ends;	堆栈段定义结束
_data segment	;定义数据段
	MSG db 'Hello,World!',13,10,'$'
_data ends;		数据段定义结束
_text segment 'code';	定义代码段
	assume cs:_text,ds:_data,ss:_stack
Start:
	mov ax,_data;	取数据内存区段地址
	mov ds,ax;	设置数据段寄存器
	cli;	设置堆栈期间,禁止响应中断
	mov ax,_stack;	取堆栈内存区段地址
	mov ss,ax;	设置堆栈段寄存器
	mov sp,offset tos;	设置初始状态时的堆栈指针
	sti
	mov dx,offset MSG
	mov ah,9
	int 21h;	中断21h的9号功能,显示ds:dx指向的字符串
	mov ax,4c00h
	int 21h;	运行结束,返回dos
_text ends;	代码段定义结束
	end Start;	源程序到此为止
