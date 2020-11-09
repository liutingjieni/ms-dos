/*************************************************************************
	> File Name: kernel/init.c
	> Author:jieni 
	> Mail: 
	> Created Time: 2020年11月05日 星期四 22时21分20秒
 ************************************************************************/
#include "init.h"
#include "print.h"
#include "timer.h"
#include "interrupt.h"

void init_all()
{
    put_str("init_all\n");
    idt_init();    //初始化中断
    timer_init();
}
