/*************************************************************************
	> File Name: inline.c
	> Author:jieni 
	> Mail: 
	> Created Time: 2020年09月05日 星期六 19时29分48秒
 ************************************************************************/

//hello world在静态区,str为helloworld所在内存的首地址
char *str = "hello world\n";

int count = 0;

void main()
{
// int $0x80 系统调用接口仅适用于32位代码.64位代码中应使用syscall系统调用(中断描述符表)
asm("pusha; \
    movl $4, %eax; \
    movl $1, %ebx; \
    movl str, %ecx; \
    movl $12, %edx; \
    int $0x80; \
    mov %eax, count; \
    popa \
    ");
}

