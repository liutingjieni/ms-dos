/*************************************************************************
	> File Name: keyboard.c
	> Author:jieni 
	> Mail: 
	> Created Time: 2020年11月19日 星期四 22时16分48秒
 ************************************************************************/

#include "keyboard.h"
#include "print.h"
#include "interrupt.h"
#include "io.h"
#include "global.h"

#define KBD_BUF_PORT 0x60 //键盘buffer寄存器端口号为0x60

static void intr_keyboard_handler(void)
{
    put_char('k');
    inb(KBD_BUF_PORT);
    return;
}

void keyboard_init()
{
    put_str("keyboard init start\n");
    register_handler(0x21, intr_keyboard_handler);
    put_str("keyboard_init done\n");
}
