/*************************************************************************
	> File Name: debug.c
	> Author:jieni 
	> Mail: 
	> Created Time: 2020年11月10日 星期二 22时19分53秒
 ************************************************************************/
#include "debug.h"
#include "print.h"
#include "interrupt.h"

void panic_spin(char *filename, int line, const char* func, const char* condition)
{
    intr_disable();

    put_str("\n\n\n!!!!!!!!!!!!!!error!!!!!!!!!!!!!\n");
    put_str("filename:");
    put_str(filename);
    put_str("\n");
    put_str("line:0x");
    put_str((char *)func);
    put_str("\n");
    put_str("function:");
    put_str((char *)func);
    put_str("\n");
    put_str("condition:");
    put_str((char*)condition);
    put_str("\n");

    while(1);
}

