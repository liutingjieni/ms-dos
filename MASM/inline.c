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

