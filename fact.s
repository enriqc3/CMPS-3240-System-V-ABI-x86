# Enrique Tapia
# CS3240
# Dr. Albert Cruz
# This program finds the value of fibonacci 13 by calling
# a function recursively 

	.file	"example_fact.c"
	.text
	.section	.rodata
.LC0:
	.string	"Fibonacci 13 is: %d\n"
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
	subq	$16, %rsp
	movl	$13, %edi
	call	my_fact
	movl	%eax, -4(%rbp)
	movl	-4(%rbp), %eax
	movl	%eax, %esi
	leaq	.LC0(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	$0, %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.globl	my_fact
	.type	my_fact, @function
my_fact:
.LFB1:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movl	%edi, -4(%rbp)
	cmpl	$1, -4(%rbp)
	jg	.L4
	movl	%edi, %eax
	jmp	.L5
.L4:
	#recursive call with n-2
	movl	-4(%rbp), %edi
	subl	$1, %edi
	call	my_fact 	#call with n-1
	movl	%eax, -8(%rbp)	#save the return value on the stack

	#recursive call with n-2
	movl	-4(%rbp), %edi
	subl	$2, %edi
	call	my_fact		#call with n-2
	addl	-8(%rbp), %eax

.L5:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE1:
	.size	my_fact, .-my_fact
	.ident	"GCC: (Debian 8.3.0-6) 8.3.0"
	.section	.note.GNU-stack,"",@progbits
