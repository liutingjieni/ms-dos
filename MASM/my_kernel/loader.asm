%include "boot.inc"

section loader vstart=LOADER_BASE_ADDR
LOADER_STACK_TOP equ LOADER_BASE_ADDR
jmp loader_start

;构建段描述符, 低32位平坦模式段基址0, 段界限fffff, 高32位 
GDT_BASE: dd 0x00000000
          dd 0x00000000

CODE_DESC: dd 0x0000ffff
           dd DESC_CODE_HIGH4

;数据段与栈段共用一个段描述符
DATA_STACK_DESC: dd 0x0000ffff  
                 dd DESC_DATA_HIGH4

;显存段不采用平坦模式
VIDEO_DESC: dd 0x80000007; limit=(0xbffff-0xb8000)/4k=0x7
           dd DESC_VIDEO_HIGH4

GDT_SIZE equ $ - GDT_BASE
GDT_LIMIT equ GDT_SIZE - 1
times 60 dq 0 ;此处预留60个描述符的空位

;构建代码段,数据段,显存段的选择子
SELECTOR_CODE equ (0x0001 << 3) + TI_GDT + RPL0 
SELECTOR_DATA equ (0x0002 << 3) + TI_GDT + RPL0
SELECTOR_VIDEO equ (0x0003 << 3) + TI_GDT + RPL0

total_mem_bytes dd 0 ;当前内存地址0xb00

gdt_ptr dw GDT_LIMIT 
        dd GDT_BASE

;人工对齐
ards_buf times 244 db 0
ards_nr dw 0

loadermsg db '2 loader in real'

loader_start:
    ;三种方法获取内存大小, biosz中断0x15子功能0xe820 0xe801 0x88 
    xor ebx, ebx
    mov edx, 0x534d4150 ;固定为签名标记
    mov di, ards_buf    ;ards缓冲区
.e820_mem_get_loop:
    mov eax, 0x0000e820
    mov ecx, 20
    int 0x15
    jc .e820_failed_so_try_e801
    add di, cx
    inc word [ards_nr]
    cmp ebx, 0
    jnz .e820_mem_get_loop

    mov cx, [ards_nr]
    mov ebx, ards_buf
    xor edx, edx

.find_max_mem_area:
    mov eax, [ebx]
    add eax, [ebx + 8]
    add ebx, 20
    cmp edx, eax

    jge .next_ards
    mov edx, eax

.next_ards:
    loop .find_max_mem_area
    jmp .mem_get_ok

.e820_failed_so_try_e801:
    mov ax, 0xe801
    int 0x15
    jc .e801_failed_so_try88

    mov cx, 0x400
    mul cx
    shl edx, 16
    and eax, 0x0000ffff
    or edx, eax
    add edx, 0x100000
    mov esi, edx

    xor eax, eax
    mov ax, bx
    mov ecx, 0x10000 
    mul ecx

    add esi, eax
    
    mov edx, esi
    jmp .mem_get_ok

.e801_failed_so_try88:
    mov ah, 0x88
    int 0x15
    jc .error_hlt
    and eax, 0x0000ffff

    mov cx, 0x400
    mul cx
    shl edx, 16
    or edx, eax
    add edx, 0x100000

.mem_get_ok:
    mov [total_mem_bytes], edx

.error_hlt:
    ;hlt

    ;------------------------------------------
    ;int 0x10  功能号:0x13  功能描述:打印字符串
    ;-----------------------------------------
    mov sp, LOADER_BASE_ADDR
    mov bp, loadermsg
    mov cx, 17      ;字符串长度
    mov ax, 0x1301  ;ah子功能号, al显示输出方式
    mov bx, 0x001f  ;bh页码, bl属性(al = 0/1)
    mov dx, 0x1000  ;dh, dl坐标
    int 0x10


    ;打开A20
    in al, 0x92
    or al, 0000_0010B
    out 0x92, al

    ;加载GDT
    lgdt [gdt_ptr]

    ;cr0第0位置1
    mov eax, cr0
    or eax, 0x00000001
    mov cr0, eax

    ;刷新流水线, 避免分支预测的影响, 这种CPU优化策略, 最怕jmp跳转
    ;这将导致之前做的预测失效, 从而起到了刷新的作用
    jmp dword SELECTOR_CODE:p_mode_start

[bits 32]
p_mode_start:
    mov ax, SELECTOR_DATA   
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, LOADER_STACK_TOP      
    mov ax,  SELECTOR_VIDEO
    mov gs, ax

    mov byte [gs:160], 'P'
    mov byte [gs:161], 0x70

    jmp $
