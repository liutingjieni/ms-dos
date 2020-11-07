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
    put_char('u');
    put_char('u');
    put_char('u');
    put_str("l am kernel\n");
    put_str("l am kernel\n");
    put_int(0x1234);
    put_int(0x1234);
    init_all();
    asm volatile("sti"); 
    while(1);
}
