/*************************************************************************
	> File Name: interrupt.h
	> Author:jieni 
	> Mail: 
	> Created Time: 2020年11月07日 星期六 20时38分48秒
 ************************************************************************/

#ifndef _INTERRUPT_H
#define _INTERRUPT_H
#include "stdint.h"
#define IDT_DESC_CNT 0x21

typedef void *intr_handler;
//中断门描述符结构体
struct gate_desc;

extern intr_handler intr_entry_table[IDT_DESC_CNT];


//初始化中断描述符
static void idt_des_init(void);
//初始化可编程中断控制器
static void pic_init(void);

//完成有关中断的所有初始化工作
void idt_init();
static void general_intr_handler(uint8_t vec_nr);
static void exception_init(void);

#endif
