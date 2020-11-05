/*************************************************************************
	> File Name: main.c
	> Author:jieni 
	> Mail: 
	> Created Time: 2020年11月02日 星期一 22时32分55秒
 ************************************************************************/
#include "print.h"
#include "init.h"

void main()
{
    put_str("l am kernel\n");
    init_all();
    asm volatile("sti");  \\为演示中断处理,在此临时开中断
    while(1);
}
