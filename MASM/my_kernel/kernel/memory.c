/*************************************************************************
	> File Name: memory.c
	> Author:jieni 
	> Mail: 
	> Created Time: 2020年11月11日 星期三 15时00分42秒
 ************************************************************************/

#include "memory.h"
#include "stdint.h"
#include "print.h"

#define PG_SIZE 4096

//0xc009f000是内核主线程栈顶, 0xc009e000是内核主线程的PCB
//一个页框大小的位图可表示128MB内存, 位图位置安排在地址0xc009a000
//这样本系统最大支持4个页框的位图
#define MEM_BITMAP BASE 0xc009a000

//0xc0000000是内核从虚拟内存3G起
//0x100000意指跨过低端1MB内存, 是虚拟地址在逻辑上连续
#define K_HEAP_START 0xc0100000

//内存池结构, 生成两个实例用于内核内存池和用户内存池
struct pool {
    struct bitmap pool_bitmap;         //位图结构, 管理物理内存
    uint32_t phy_addr_start;           //物理内存起始地址
    uint32_t pool_size;                //字节容量
};

struct pool kernel_pool, user_pool;
struct virtual_addr kernel_vaddr;

static void mem_pool_init(uint32_t all_mem) 
{
    put_str("  mem_pool_init strat\n");

    uint32_t page_table_size = PG_SIZE *256;
    uint32_t user_mem = page_table_size + 0x100000;
    uint32_t free_mem = all_mem - used_mem;
    uint16_t all_free_pages = free_mem / PG_SIZE;
}

 :NERDTreeToggle


