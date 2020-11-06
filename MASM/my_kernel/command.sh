#!/bin/bash 
gcc -I lib/kernel/ -I lib/ -I kernel -c -fno-builtin -o main.o kernel/main.c -m32
nasm -f elf -o build/print.o lib/kernel/print.asm && 
nasm -f elf -o build/kernel.o kernel/kernel.asm && 
gcc -I lib/kernel/ -I lib -I kernel/ -c -fno-builtin -o build/interrupt.o build/interrupt.c -m32 && 
gcc -I lib/kernel/ -I lib -I kernel/ -c -fno-builtin -o build/init.o kernel/init.c -m32 && 
ld -Ttext 0xc0001500 -e main  -m elf_i386 -o build/kernel.bin build/main.o build/init.o build interrupt.o build/print.o build/kernel.o && 
dd if=kernel/kernel.bin of=~/c.img bs=512 count=200 seek=9 conv=notrunc

