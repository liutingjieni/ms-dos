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

int main(void)
{
    put_str("l am kernel\n");
    put_int(0x1234);
    put_int(0x1234);
    init_all();
    //ASSERT(1==2);
    void *addr = get_kernel_pages(3);
    put_str("\n get_kernel_pages start vaddr is ");
    put_int((uint32_t)addr);
    while(1);
    return 0;
}
