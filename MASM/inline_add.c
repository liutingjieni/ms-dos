/*************************************************************************
	> File Name: inline_add.c
	> Author:jieni 
	> Mail: 
	> Created Time: 2020年09月05日 星期六 20时32分57秒
 ************************************************************************/

#include <stdio.h>

int in_a = 1, in_b = 2, out_sum;

void main()
{
asm("pusha; \
    movl in_a, %eax; \
    movl in_b, %ebx; \
    addl %ebx, %eax; \
    movl %eax, out_sum; \
    popa");
    printf("%d\n", out_sum);
}
