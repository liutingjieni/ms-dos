/*************************************************************************
	> File Name: memory.h
	> Author:jieni 
	> Mail: 
	> Created Time: 2020年11月11日 星期三 14时59分15秒
 ************************************************************************/

#ifndef _MEMORY_H
#define _MEMORY_H
#include "stdint.h"
#include "bitmap.h"


struct virtual_addr {
    struct bitmap vaddr_bitmap;     //虚拟地址用到的位图结构
    uint32_t vaddr_start;           //虚拟地址起始地址
};

extern struct pool kernel_pool, user_pool;

void mem_init(void);
#endif
