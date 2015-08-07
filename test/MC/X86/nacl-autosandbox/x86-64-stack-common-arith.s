// RUN: llvm-mc -nacl-enable-auto-sandboxing -filetype asm -triple x86_64-unknown-nacl %s | FileCheck %s --check-prefix=X8664
.scratch %r11

	add $12, %rsp
//X8664:    	.bundle_lock
//X8664-NEXT: 	addl	$12, %esp
//X8664-NEXT: 	leaq	(%rsp,%r15), %rsp
//X8664-NEXT: 	.bundle_unlock

	add $131072, %rsp
//X8664:    	.bundle_lock
//X8664-NEXT: 	addl	$131072, %esp           
//X8664-NEXT: 	leaq	(%rsp,%r15), %rsp
//X8664-NEXT: 	.bundle_unlock

	add $12, %rbp
//X8664:    	.bundle_lock
//X8664-NEXT: 	addl	$12, %ebp
//X8664-NEXT: 	leaq	(%rbp,%r15), %rbp
//X8664-NEXT: 	.bundle_unlock

	add $12, %esp
//X8664:    	.bundle_lock
//X8664-NEXT: 	addl	$12, %esp
//X8664-NEXT: 	leaq	(%rsp,%r15), %rsp
//X8664-NEXT: 	.bundle_unlock

	add $12, %ebp
//X8664:    	.bundle_lock
//X8664-NEXT: 	addl	$12, %ebp
//X8664-NEXT: 	leaq	(%rbp,%r15), %rbp
//X8664-NEXT: 	.bundle_unlock


	sub $12, %rsp
//X8664:    	.bundle_lock
//X8664-NEXT: 	subl	$12, %esp
//X8664-NEXT: 	leaq	(%rsp,%r15), %rsp
//X8664-NEXT: 	.bundle_unlock

	sub $131072, %rsp
//X8664:    	.bundle_lock
//X8664-NEXT: 	subl	$131072, %esp           
//X8664-NEXT: 	leaq	(%rsp,%r15), %rsp
//X8664-NEXT: 	.bundle_unlock


	sub $12, %rbp
//X8664:    	.bundle_lock
//X8664-NEXT: 	subl	$12, %ebp
//X8664-NEXT: 	leaq	(%rbp,%r15), %rbp
//X8664-NEXT: 	.bundle_unlock

	sub $131072, %rbp
//X8664:    	.bundle_lock
//X8664-NEXT: 	subl	$131072, %ebp           
//X8664-NEXT: 	leaq	(%rbp,%r15), %rbp
//X8664-NEXT: 	.bundle_unlock


	and $-128, %rsp
//X8664:    	andq	$-128, %rsp

	and $-128, %esp
//X8664:    	.bundle_lock
//X8664-NEXT: 	andl	$-128, %esp
//X8664-NEXT: 	leaq	(%rsp,%r15), %rsp
//X8664-NEXT: 	.bundle_unlock

	and $131072, %rsp
//X8664:    	.bundle_lock
//X8664-NEXT: 	andl	$131072, %esp           
//X8664-NEXT: 	leaq	(%rsp,%r15), %rsp
//X8664-NEXT: 	.bundle_unlock


	and $-128, %rbp
//X8664:    	.bundle_lock
//X8664-NEXT: 	andl	$-128, %ebp
//X8664-NEXT: 	leaq	(%rbp,%r15), %rbp
//X8664-NEXT: 	.bundle_unlock

	and $131072, %rbp
//X8664:    	.bundle_lock
//X8664-NEXT: 	andl	$131072, %ebp           
//X8664-NEXT: 	leaq	(%rbp,%r15), %rbp
//X8664-NEXT: 	.bundle_unlock


	lea -12(%rbp), %rsp
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	-12(%rbp), %esp
//X8664-NEXT: 	leaq	(%rsp,%r15), %rsp
//X8664-NEXT: 	.bundle_unlock

	lea 12(%rsp), %rsp
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	12(%rsp), %esp
//X8664-NEXT: 	leaq	(%rsp,%r15), %rsp
//X8664-NEXT: 	.bundle_unlock


	lea -12(%rbp), %rbp
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	-12(%rbp), %ebp
//X8664-NEXT: 	leaq	(%rbp,%r15), %rbp
//X8664-NEXT: 	.bundle_unlock

	lea 12(%rsp), %rbp
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	12(%rsp), %ebp
//X8664-NEXT: 	leaq	(%rbp,%r15), %rbp
//X8664-NEXT: 	.bundle_unlock


	lea 12(%rsp, %rax), %rsp
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	.bundle_lock
//X8664-NEXT: 	leal	12(%rsp,%rax), %esp
//X8664-NEXT: 	.bundle_unlock
//X8664-NEXT: 	leaq	(%rsp,%r15), %rsp
//X8664-NEXT: 	.bundle_unlock

	lea 12(%rsp, %rax), %rbp
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	.bundle_lock
//X8664-NEXT: 	leal	12(%rsp,%rax), %ebp
//X8664-NEXT: 	.bundle_unlock
//X8664-NEXT: 	leaq	(%rbp,%r15), %rbp
//X8664-NEXT: 	.bundle_unlock
	

	lea (%rax, %rbx), %rsp
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	(%rax,%rbx), %r11d
//X8664-NEXT: 	.bundle_lock
//X8664-NEXT: 	leal	(%r15,%r11), %esp
//X8664-NEXT: 	.bundle_unlock
//X8664-NEXT: 	leaq	(%rsp,%r15), %rsp
//X8664-NEXT: 	.bundle_unlock

	lea (%rax, %rbx), %rbp
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	(%rax,%rbx), %r11d
//X8664-NEXT: 	.bundle_lock
//X8664-NEXT: 	leal	(%r15,%r11), %ebp
//X8664-NEXT: 	.bundle_unlock
//X8664-NEXT: 	leaq	(%rbp,%r15), %rbp
//X8664-NEXT: 	.bundle_unlock


	lea (%rax, %rbx), %esp
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	(%rax,%rbx), %esp
//X8664-NEXT: 	leaq	(%rsp,%r15), %rsp
//X8664-NEXT: 	.bundle_unlock

	lea (%rax, %rbx), %ebp
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	(%rax,%rbx), %ebp
//X8664-NEXT: 	leaq	(%rbp,%r15), %rbp
//X8664-NEXT: 	.bundle_unlock

