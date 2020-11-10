#!/bin/bash 
nasm -f elf -o build/print.o lib/kernel/print.asm && 
nasm -f elf -o build/kernel.o kernel/kernel.asm && 
gcc -I lib/kernel/ -I lib/  -I device/ -c -fno-builtin -o build/init.o kernel/init.c -m32 &&
gcc -I lib/kernel/ -I lib/  -c -fno-builtin -o build/interrupt.o kernel/interrupt.c -m32 &&
gcc -I lib/kernel/ -I lib/  -c -fno-builtin -o build/timer.o device/timer.c -m32 &&
gcc -I lib/kernel/ -I lib/  -c -fno-builtin -o build/main.o kernel/main.c -m32 &&
gcc -I kernel/ -I lib/kernel/ -I lib/  -I device/ -c -fno-builtin -o build/debug.o kernel/debug.c -m32 &&
ld -Ttext 0xc0001500 -e main -o build/kernel.bin -m elf_i386  build/main.o  build/print.o build/kernel.o build/init.o build/interrupt.o build/timer.o build/debug.o&& 
dd if=build/kernel.bin of=~/c.img bs=512 count=200 seek=9 conv=notrunc

