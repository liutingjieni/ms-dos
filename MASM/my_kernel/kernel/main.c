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
#include "thread.h"
#include "list.h"
#include "console.h"
void k_thread_a(void *);
void k_thread_b(void *);

int main(void)
{
    put_str("l am kernel\n");
    init_all();
    //ASSERT(1==2);
    //thread_start("k_thread_a", 31, k_thread_a, "argA ");
    //thread_start("k_thread_b", 8, k_thread_b, "argB ");
    intr_enable();
    
    while(1);
    //while(1)
    //{
    //   // put_str("Main ");
    //    console_put_str("Main ");
    //}
    return 0;
}

void k_thread_a(void *arg)
{
    char *para = arg;
    while (1) {
        //put_str(para);
        console_put_str(para);
    }
}

void k_thread_b(void *arg)
{
    char *para = arg;
    while (1) {
        //put_str(para);
       console_put_str(para);
    }
}

