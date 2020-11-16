/*************************************************************************
	> File Name: main.c
	> Author:jieni 
	> Mail: 
	> Created Time: 2020年11月02日 星期一 22时32分55秒
 ************************************************************************/
#include "print.h"
#include "init.h"
#include "debug.h"
#include "memory.h"
#include "thread.h"
#include "interrupt.h"
void k_thread_a(void *);
void k_thread_b(void *);

int main(void)
{
    put_str("l am kernel\n");
    put_int(0x1234);
    put_int(0x1234);
    init_all();
    //ASSERT(1==2);
    put_str("main ");
    //thread_start("k_thread_a", 31, k_thread_a, "argA");
    //thread_start("k_thread_b", 8, k_thread_a, "argB");
    put_str("lalall");
    intr_enable();
    //asm volatile("sti");
    while(1)
    {
        put_str("main ");
    }
    return 0;
}

void k_thread_a(void *arg)
{
    put_str("***************\n");
    char *para = arg;
    while (1) {
        put_str(para);
    }
}

void k_thread_b(void *arg)
{
    char *para = arg;
    while (1) {
        put_str(para);
    }
}
