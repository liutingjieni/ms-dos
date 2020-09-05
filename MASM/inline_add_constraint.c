/*************************************************************************
	> File Name: inline_add_constraint.c
	> Author:jieni 
	> Mail: 
	> Created Time: 2020年09月05日 星期六 20时37分40秒
 ************************************************************************/

#include <stdio.h>

void main()
{
    int in_a = 1, in_b = 2, out_sum;
    asm("addl %%ebx, %%eax":"=a"(out_sum) : "a"(in_a), "b"(in_b));
    printf("%d\n", out_sum);
}
