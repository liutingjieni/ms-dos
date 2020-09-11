section MBR vstart=0x7c00
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov ss, ax
    mov sp, 0x7c00
    mov ax, 0xb800
    mov gs, ax

    mov ax, 0600h
    mov bx, 0700h
    mov cx, 0
    mov dx, 184fh

    int 10h

    mov byte [gs:0x00], '1'
    mov byte [gs:0x01], 0xA4

    mov byte [gs:0x02], ' '
    mov byte [gs:0x03], 0xA4

    mov byte [gs:0x04], 'M'
    mov byte [gs:0x05], 0xA4
    
    mov byte [gs:0x06], 'B'
    mov byte [gs:0x07], 0xA4
    
    mov byte [gs:0x08], 'R'
    mov byte [gs:0x09], 0xA4

    mov eax, LOADER_START_SECTOR
    mov bx, LOADER_START_ADDR
    mov cx, 1
    call rd_disk_m_16

    jmp LOADER_START_ADDR

rd_disk_m_16: 
                        ;eax=LBA扇区号
                        ;bx=将数据写入的内存地址
                        ;cx=读入的扇区数
    mov esi, eax ;
    mov al, cl

    mov dx, 0x1f2
    mov al,cl
    out dx, al

    mov eax, esi

    mov dx, 0x1f3
    out dx, al

    mov cl, 8
    shr eax, cl
    mov dx, 0x1f5
    out dx, al
    shr eax, cl
    mov dx, 0x1f5
    out dx, al
    shr eax, cl
    mov dx, 0x1f5
    out dx, al

