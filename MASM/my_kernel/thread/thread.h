/*************************************************************************
	> File Name: thread.h
	> Author:jieni 
	> Mail: 
	> Created Time: 2020年11月13日 星期五 11时01分36秒
 ************************************************************************/

#ifndef _THREAD_H
#define _THREAD_H
#include "stdint.h"
#include "list.h"
//自定义通用函数类型, 他将在很多线程中作为形参类型
typedef void thread_func(void *);

//进程或线程的状态
enum task_status {
    TASK_RUNNING,
    TASK_READY,
    TASK_BLOCKED,
    TASK_WAITING,
    TASK_HANGING,
    TASK_DIED
};

//-------------中断栈intr_stack-----------------------------
//此结构用与中断发生时保护程序(进程或线程)的上下文环境
//进程或线程被外部中断或软中断打断时, 会按照此结构压入上下文
//寄存器, intr_exit中的出栈操作是此结构的逆结构
//此栈在线程自己的内核栈中位置固定, 所在页的最顶端
//----------------------------------------------------------
struct intr_stack {
    uint32_t vec_no;
    uint32_t edi;
    uint32_t esi;
    uint32_t ebp;
    uint32_t esp_dummy;   //虽然pushad把esp也压入, 但esp是不断变化的, 所以会被popad忽略
    uint32_t ebx;
    uint32_t edx;
    uint32_t ecx;
    uint32_t eax;
    uint32_t gs;
    uint32_t fs;
    uint32_t ed;
    uint32_t ds;

    //以下是由cpu从低特权级进入高特权级时压入
    uint32_t err_code;
    void (*eip)(void);
    uint32_t cs;
    uint32_t eflags;
    void *esp;
    uint32_t ss;
};

//--------------------线程栈thread_stack--------------------
//线程自己的栈, 用于存储线程中待执行的函数
//此结构在线程自己的内核栈中位置不固定
//仅用在switch_to时保存线程环境
//实际位置取决于实际运行环境
//----------------------------------------------------------
struct thread_stack {
    uint32_t ebp;
    uint32_t ebx;
    uint32_t edi;
    uint32_t esi;

    //线程第一次执行时, eip执向待调用的函数kernel_thread
    //其他时候, eip指向switch_to的返回地址
    void (*eip)(thread_func *func, void *func_arg);

    //-----以下仅供第一次被调度上CPU时使用-----------------
    //参数unused_ret只为占位置充数为返回地址
    void (*unused_retaddr);
    thread_func* function;        //由kernel_thread所调用的函数名
    void *func_arg;               //由kernel_thread所调用的函数所需的参数
};

//线程或进程的PCB,程序控制块
struct task_struct {
    uint32_t *self_kstack;
    enum task_status status;
    char name[16];
    uint8_t priority;
    uint8_t ticks;                 //每次在处理器上执行的时间滴答数
    uint32_t elapsed_ticks;        //此任务自上CPU运行后至今占用了多少滴答数
    struct list_elem general_tag;  //general_tag的作用是用于线程在一般的队列中的结点
    struct list_elem all_list_tag; //用于线程队列thread_all_list中的结点
    uint32_t *pgdir;               //进程自己页表的虚拟地址
    uint32_t stack_magic;          //这串数字做栈的边界标记. 用于检测栈的溢出
};
struct task_struct *thread_start(char *name, int prio, thread_func function, void *func_arg);
struct task_struct *running_thread();
void schedule();
void thread_init();

#endif