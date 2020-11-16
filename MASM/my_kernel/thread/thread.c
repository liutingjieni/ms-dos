/*************************************************************************
	> File Name: thread.c
	> Author:jieni 
	> Mail: 
	> Created Time: 2020年11月13日 星期五 11时36分27秒
 ************************************************************************/

#include "thread.h"
#include "stdint.h"
#include "string.h"
#include "global.h"
#include "memory.h"
#include "interrupt.h"
#include "print.h"
#include "switch.h"
#define PG_SIZE 4096

struct task_struct *main_thread;     //主线程PCB
struct list thread_ready_list;       //就绪队列
struct list thread_all_list;         //所有任务队列
static struct list_elem *thread_tag; //用于保存队列中的线程结点

extern void switch_to(struct task_struct *cur, struct task_struct *next);

struct task_struct *running_thread()
{
    uint32_t esp;
    asm("mov %%esp, %0" : "=g"(esp));
    return (struct task_struct*)(esp & 0xfffff000);
}

static void kernel_thread(thread_func *function, void *func_arg)
{
    intr_enable();
    function(func_arg);
}


//初始化线程栈thread_stack, 将待执行的函数和参数放在thread_stack相应的位置
void thread_create(struct task_struct* pthread, thread_func function, void *func_arg)
{
    //预留出中断使用栈的空间
    pthread->self_kstack -= sizeof(struct intr_stack);
    //预留出线程栈的空间
    pthread->self_kstack -= sizeof(struct thread_stack);

    struct thread_stack *kthread_stack = (struct thread_stack*)pthread->self_kstack;
    kthread_stack->eip = kernel_thread;
    kthread_stack->function = function;
    kthread_stack->func_arg = func_arg;
    kthread_stack->ebp = kthread_stack->ebx = kthread_stack->esi = kthread_stack->edi = 0;
}

//初始化线程基本信息
void init_thread(struct task_struct* pthread, char *name, int prio)
{
    memset(pthread, 0, sizeof(*pthread));
    strcpy(pthread->name, name);
    if (pthread == main_thread) {
        pthread->status = TASK_RUNNING;
    }
    else {
        pthread->status = TASK_READY;
    }
    pthread->status = TASK_RUNNING;
    pthread->priority = prio;
    //self_kstack是线程自己在内核状态下使用的栈顶地址
    pthread->self_kstack = (uint32_t *)((uint32_t)pthread + PG_SIZE); 
    pthread->ticks = prio;
    pthread->elapsed_ticks = 0;
    pthread->pgdir = NULL;
    pthread->stack_magic = 0x19870916;
}

struct task_struct *thread_start(char *name, int prio, thread_func function, void *func_arg)
{
    struct task_struct *thread = get_kernel_pages(1);

    init_thread(thread, name, prio);
    thread_create(thread, function, func_arg);

    ASSERT(!elem_find(&thread_ready_list, &thread->general_tag));
    list_append(&thread_ready_list, &thread->general_tag);
    ASSERT(!elem_find(&thread_all_list, &thread->all_list_tag));
    list_append(&thread_all_list, &thread->all_list_tag);

    //asm volatile("movl %0, %%esp;pop %%ebp; pop %%ebx; pop %%edi; pop %%esi; ret" : : "g"(thread->self_kstack): "memory");
    return thread;
}

static void make_main_thread(void)
{
    main_thread = running_thread();
    init_thread(main_thread, "main", 310000);
    ASSERT(!elem_find(&thread_all_list, &main_thread->all_list_tag));
    list_append(&thread_all_list, &main_thread->all_list_tag);
}

void schedule()
{
    ASSERT(intr_get_status() == INTR_OFF);

    struct task_struct *cur = running_thread();
    if (cur->status == TASK_RUNNING) {
        ASSERT(!elem_find(&thread_ready_list, &cur->general_tag));
        list_append(&thread_ready_list, &cur->general_tag);
        cur->ticks = cur->priority;
        cur->status = TASK_READY;
    }
    else {
        
    }
    ASSERT(!list_empty(&thread_ready_list));
    thread_tag = NULL;
    thread_tag = list_pop(&thread_ready_list);
    struct task_struct *next = elem2entry(struct task_struct, general_tag, thread_tag);
    next->status = TASK_RUNNING;
    put_int(cur);
    put_int(next);
    put_str("\n");
    switch_to(cur, next);
}

void thread_init()
{
    put_str("thread_init start");
    list_init(&thread_ready_list);
    list_init(&thread_all_list);
    make_main_thread();
    put_str("thread_init done\n");
}
