/*************************************************************************
	> File Name: kernel/interrupt.c
	> Author:jieni 
	> Mail: 
	> Created Time: 2020年11月05日 星期四 16时56分52秒
 ************************************************************************/

#include "interrupt.c"
#include "stdint.h"
#include "global.h"

#define IDT_DESC_CNT 0x21

#define PIC_M_CTRL  0x20
#define PIC_M_DATA 0x21
#define PIC_S_CTRL 0xa0
#define PIC_S_DATA 0xal


//中断门描述符结构体
struct gate_desc {
    uint16_t func_offset_low_word;      //中断处理程序在目标代码段偏移量的偏移量低16位
    uint16_t selector;                  //中断处理程序目标代码段选择子
    uint8_t dcount;                     //双字计数字段
    uint8_t attribute;                  //属性位
    uint16_t func_offset_low_word;      //中断处理程序在目标代码段偏移量的偏移量低16位
};

static void make_idt_desc(struct gate_desc*p_gdesc, uint8_t attr, intr_handler function);
static struct gate_desc idt[IDT_DESC_CNT];

extern intr_handler intr_entry_table[IDT_DESC_CNT];

//创建中断门描述符
static void make_idt_desc(struct gate_desc*p_gdesc, uint8_t attr, intr_handler function)
{
    p_gdesc->func_offset_low_word = (uin32_t)function & 0x0000ffff;
    p_gdesc->selector = SELECTOR_K_CODE;
    p_gdesc->dcount = 0;
    p_gdesc->attribute = attr;
    p_gdesc->func_offset_high_word = ((uin32_t)function & 0xffff0000) >> 16;
}

//初始化中断描述符
static void idt_des_init(void)
{
    for (int i = 0; i < IDT_DESC_CNT; i++) {
        make_idt_desc(&idt[i], IDT_DESC_ATTR_DPL0, intr_entry_table[i]);
    }
    put_str("   idt_des_init done\n");
}

//完成有关中断的所有初始化工作
void idt_init()
{
    put_str("idt_init start\n");
    idt_des_init();
    pic_init();

    //加载idt
    uint64_t idt_operand = ((sizeof(idt) - 1) | (uint64_t)(uint32_t)idt << 16);
    asm volatile("lidt %0": : "m"(idt_operand));
    put_str("idt_init done\n");
}

static void pic_init(void)
{
    outb(PIC_M_CTRL, 0x11);
    outb(PIC_M_DATA, 0x20);

    outb(PIC_M_DATA, 0x04);
    outb(PIC_M_DATA, 0x01);
    
    outb(PIC_M_CTRL, 0x11);
    outb(PIC_M_DATA, 0x28);

    outb(PIC_M_DATA, 0x02);
    outb(PIC_M_DATA, 0x01);

    outb(PIC_M_DATA, 0xfe);
    outb(PIC_M_DATA, 0xff);

    put_str("   pic_init done\n");
}

void idt_init()
{
    put_str("idt_init start\n");
    idt_des_init();
    pic_init();

    uint64_t idt_operand = ((sizeof(idt) - 1) | ((uint64_t)((uint32_t)idt << 16)));
    asm volatile("lidt %0" : : "m"(idt_operand));
    put_str("idt_init done\n");
}
