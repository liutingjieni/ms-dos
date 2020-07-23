        ;代码清单6-1
         ;文件名：c06_mbr.asm
         ;文件说明：硬盘主引导扇区代码
         ;创建日期：2011-4-12 22:12 
      
         jmp near start    ;跳过非指令的数据区
         
  mytext db 'L',0x07,'a',0x07,'b',0x07,'e',0x07,'l',0x07,' ',0x07,'o',0x07,\
            'f',0x07,'f',0x07,'s',0x07,'e',0x07,'t',0x07,':',0x07
  number db 0,0,0,0,0   ;保存分解的数位
  
  start:
         ;设置数据段寄存器DS的内容为0x07c0,主引导扇区加载内存地址(0x0000:0x7c000), 段寄存器为0x0000, 偏移地址与编译后的段内相对地址不一致
         mov ax,0x7c0                  ;设置数据段基地址 
         mov ds,ax                     
         
         ;段寄存器ES的内容指向显示缓冲区所在的段基址0xb800
         mov ax,0xb800                 ;设置附加段基地址 
         mov es,ax
         
         cld     ;设置正向传送:从内存的低地址到高地址; std为反向传送
         mov si,mytext                 
         mov di,0
         mov cx,(number-mytext)/2      ;实际上等于 13
         rep movsw  ;es:di<-ds:si,传送字节数由cx决定,movsw每次传送一个字(两个字节), movsb传送一个字节
                    ;单纯的mobsw只能执行一次,如果希望处理器能自动执行,需要加上前缀rep,意思是CX不为0则重复. 
         
         
         ;计算各个数位
         mov ax,number                 ;得到标号所代表的偏移地址
         mov bx,ax                     ;bx表示number,即分解出来的数的保存地址
         mov cx,5                      ;循环次数 
         mov si,10                     ;除数 
  digit: 
         xor dx,dx
         div si      ;dx:ax<-dx:ax/si
         mov [bx],dl                   ;保存数位
         inc bx     ;bx自加
         loop digit                    ;将寄存器cx的内容减1,如果CX的内容不为零,转移到指定的位置处,否则顺序执行后面的指令
         
         ;显示各个数位
         mov bx,number 
         mov si,4                      ;si,di为变址寄存器
   show:
         mov al,[bx+si]
         add al,0x30                   ;得到对应的ascii码
         mov ah,0x04                   ;0x04是属性,采用低端字节序
         mov [es:di],ax
         add di,2
         dec si
         jns show                      ;当SF!=0,跳到show处
         
         mov word [es:di],0x0744

         jmp near $                   ;无限循环

  times 510-($-$$) db 0               ;$是当前行的汇编地址, $$是当前汇编节(段)的起始汇编地址,是NASM编译器的标记
                                      ;用来填充硬盘中前512字节的空白
                   db 0x55,0xaa       ;最好两个字节为启动引导扇区代码的规定
