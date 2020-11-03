#!/bin/bash
nasm -f elf -o lib/kernel/print.o lib/kernel/print.asm && gcc -I lib/kernel/ -c -o kernel/main.o kernel/main.c -m32 && ld -Ttext 0xc0001500 -e main  -m elf_i386 -o kernel/kernel.bin kernel/main.o lib/kernel/print.o && dd if=kernel/kernel.bin of=~/c.img bs=512 count=200 seek=9 conv=notrunc

