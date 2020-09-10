	.file	"inline.c"
	.globl	str
	.section	.rodata
.LC0:
	.string	"hello world\n"
	.section	.data.rel.local,"aw",@progbits
	.align 8
	.type	str, @object
	.size	str, 8
str:
	.quad	.LC0
	.globl	count
	.bss
	.align 4
	.type	count, @object
	.size	count, 4
count:
	.zero	4
	.text
	.globl	main
	.type	main, @function
main:
.LFB0:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
#APP
# 16 "inline.c" 1
	pusha;     movl $4, %eax;     movl $1, %ebx;     movl str, %ecx;     movl $12, %edx;     int $0x80;     mov %eax, count;     popa     
# 0 "" 2
#NO_APP
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.ident	"GCC: (Debian 6.3.0-18+deb9u1) 6.3.0 20170516"
	.section	.note.GNU-stack,"",@progbits
