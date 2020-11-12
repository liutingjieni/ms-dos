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
#define MEM_BITMAP_BASE 0xc009a000

//0xc0000000是内核从虚拟内存3G起
//0x100000意指跨过低端1MB内存, 是虚拟地址在逻辑上连续
#define K_HEAP_START 0xc0100000

//内存池结构, 生成两个实例用于内核内存池和用户内存池
struct pool {
    struct bitmap pool_bitmap;         //位图结构, 管理物理内存
    uint32_t phy_addr_start;           //本内存池所管理物理内存的起始地址
    uint32_t pool_size;                //本内存池字节容量
};

struct pool kernel_pool, user_pool;
struct virtual_addr kernel_vaddr;

static void mem_pool_init(uint32_t all_mem) 
{
    put_str("  mem_pool_init strat\n");

    //用来记录页目录表和页表占用的字节大小
    //第0个和第768个页目录项指向同一个页表, 共享这一页框的空间
    //页目录表中最后一个页目录项指向页目录项本身
    //769~1022个页目录项共254
    //1 + 1 + 254 = 256
    uint32_t page_table_size = PG_SIZE *256;
    //记录当前可以使用的物理内存地址
    uint32_t used_mem = page_table_size + 0x100000;
    //用来存储目前可用的内存字节数
    uint32_t free_mem = all_mem - used_mem;
    //用来保存可用内存字节数free_mem转换成对的物理页数
    uint16_t all_free_pages = free_mem / PG_SIZE;

    //为简化操作, 余数不操作, 坏处是这样做会丢失内存, 好处是不用做内存的越界检查. 
    //因为位图表示的内存少于实际物理内存
    //kernel可用的物理页数
    uint16_t kernel_free_pages = all_free_pages / 2;
    //user可用的物理页数
    uint16_t user_free_pages = all_free_pages - kernel_free_pages;

    //kernel bitmap的长度, 位图中一位表示一页
    uint32_t kbm_length = kernel_free_pages / 8;
    //user bitmap的长度
    uint32_t ubm_length = user_free_pages / 8;
    //内核可用的物理内存起始地址
    uint32_t kp_start = used_mem;
    //user可用的物理内存起始地址
    uint32_t up_start = kp_start + kernel_free_pages * PG_SIZE;

    kernel_pool. phy_addr_start = kp_start;
    user_pool.phy_addr_start = up_start;

    kernel_pool.pool_size = kernel_free_pages * PG_SIZE;
    user_pool.pool_size = user_free_pages * PG_SIZE;

    kernel_pool.pool_bitmap.btmp_bytes_len = kbm_length;
    user_pool.pool_bitmap.btmp_bytes_len = ubm_length;


    //MEM_BITMAP_BASE定义出解释了0xc009a000的出现的原因
    kernel_pool.pool_bitmap.bits = (void *)MEM_BITMAP_BASE;
    //用户内存池的位图紧跟在内核内存池位图之后
    user_pool.pool_bitmap.bits = (void *)(MEM_BITMAP_BASE + kbm_length);

    //
    put_str("  kernel_pool_bitmap_start:");
    put_int((int)kernel_pool.pool_bitmap.bits);
    put_str(" kernel_pool_phy_addr_start:");
    put_int(kernel_pool.phy_addr_start);
    put_str("\n");
    put_str("user_pool_bitmap_start:");
    put_int((int)user_pool.pool_bitmap.bits);
    put_str(" user_pool_phy_addr_start:");
    put_int(user_pool.phy_addr_start);
    put_str("\n");

    bitmap_init(&kernel_pool.pool_bitmap);
    bitmap_init(&user_pool.pool_bitmap);

    kernel_vaddr.vaddr_bitmap.btmp_bytes_len = kbm_length;
    kernel_vaddr.vaddr_bitmap.bits = (void *)(MEM_BITMAP_BASE + kbm_length + ubm_length);

    kernel_vaddr.vaddr_start = K_HEAP_START;
    bitmap_init(&kernel_vaddr.vaddr_bitmap);

    put_str(" mem_pool_init done \n");
}

//内存管理部分初始化入口
void mem_init()
{
    put_str("mem_init start\n");
    uint32_t mem_bytes_total = (*(uint32_t *)(0xb03));
    put_str("********\n");
    put_int(mem_bytes_total);
    mem_pool_init(mem_bytes_total);
    put_str("mem_init done\n");

}
