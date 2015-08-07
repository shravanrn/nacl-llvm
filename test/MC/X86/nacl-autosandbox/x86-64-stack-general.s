// RUN: llvm-mc -nacl-enable-auto-sandboxing -filetype asm -triple x86_64-unknown-nacl %s | FileCheck %s --check-prefix=X8664
.scratch %r11

	mov 12(%rsp), %rsp
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	12(%rsp), %esp
//X8664-NEXT: 	leaq	(%rsp,%r15), %rsp
//X8664-NEXT: 	.bundle_unlock

	mov 131072(%rax, %rdi, 8), %rsp
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	.bundle_lock
//X8664-NEXT: 	movl	(%r15,%r11), %esp
//X8664-NEXT: 	.bundle_unlock
//X8664-NEXT: 	leaq	(%rsp,%r15), %rsp
//X8664-NEXT: 	.bundle_unlock
	

	imulq 12(%rsp), %rsp
//X8664:    	.bundle_lock
//X8664-NEXT: 	imull	12(%rsp), %esp
//X8664-NEXT: 	leaq	(%rsp,%r15), %rsp
//X8664-NEXT: 	.bundle_unlock

	imulq 131072(%rax, %rdi, 8), %rsp
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	.bundle_lock
//X8664-NEXT: 	imull	(%r15,%r11), %esp
//X8664-NEXT: 	.bundle_unlock
//X8664-NEXT: 	leaq	(%rsp,%r15), %rsp
//X8664-NEXT: 	.bundle_unlock


	shlq $7, %rbp
//X8664:    	.bundle_lock
//X8664-NEXT: 	shll	$7, %ebp
//X8664-NEXT: 	leaq	(%rbp,%r15), %rbp
//X8664-NEXT: 	.bundle_unlock


	adc $12, %rsp
//X8664:    	.bundle_lock
//X8664-NEXT: 	adcl	$12, %esp
//X8664-NEXT: 	leaq	(%rsp,%r15), %rsp
//X8664-NEXT: 	.bundle_unlock


	neg %esp
//X8664:    	.bundle_lock
//X8664-NEXT: 	negl	%esp
//X8664-NEXT: 	leaq	(%rsp,%r15), %rsp
//X8664-NEXT: 	.bundle_unlock


	pext 12(%rsp), %rsp, %rbp
//X8664:    	.bundle_lock
//X8664-NEXT: 	pextl	12(%rsp), %esp, %ebp
//X8664-NEXT: 	leaq	(%rbp,%r15), %rbp
//X8664-NEXT: 	.bundle_unlock


	popcnt (%rax, %rbx), %rsp
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	(%rax,%rbx), %r11d
//X8664-NEXT: 	.bundle_lock
//X8664-NEXT: 	popcntl	(%r15,%r11), %esp
//X8664-NEXT: 	.bundle_unlock
//X8664-NEXT: 	leaq	(%rsp,%r15), %rsp
//X8664-NEXT: 	.bundle_unlock


	rorx $12, %rax, %rsp
//X8664:    	.bundle_lock
//X8664-NEXT: 	rorxl	$12, %eax, %esp
//X8664-NEXT: 	leaq	(%rsp,%r15), %rsp
//X8664-NEXT: 	.bundle_unlock


	movd %xmm0, %rsp
//X8664:    	.bundle_lock
//X8664-NEXT: 	movd	%xmm0, %esp
//X8664-NEXT: 	leaq	(%rsp,%r15), %rsp
//X8664-NEXT: 	.bundle_unlock


	tzcnt %rsp, %rsp
//X8664:    	.bundle_lock
//X8664-NEXT: 	tzcntl	%esp, %esp
//X8664-NEXT: 	leaq	(%rsp,%r15), %rsp
//X8664-NEXT: 	.bundle_unlock


	cvtss2si %xmm0, %rsp
//X8664:    	.bundle_lock
//X8664-NEXT: 	cvtss2si	%xmm0, %esp
//X8664-NEXT: 	leaq	(%rsp,%r15), %rsp
//X8664-NEXT: 	.bundle_unlock


	vcvtss2si 12(%rsp), %rsp
//X8664:    	.bundle_lock
//X8664-NEXT: 	vcvtss2si	12(%rsp), %esp
//X8664-NEXT: 	leaq	(%rsp,%r15), %rsp
//X8664-NEXT: 	.bundle_unlock

	vcvtss2si 131072(%rax, %rdi, 8), %rsp
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	.bundle_lock
//X8664-NEXT: 	vcvtss2si	(%r15,%r11), %esp
//X8664-NEXT: 	.bundle_unlock
//X8664-NEXT: 	leaq	(%rsp,%r15), %rsp
//X8664-NEXT: 	.bundle_unlock


	xchg %rax, %rsp
//X8664:    	.bundle_lock
//X8664-NEXT: 	xchgl	%esp, %eax
//X8664-NEXT: 	leaq	(%rsp,%r15), %rsp
//X8664-NEXT: 	.bundle_unlock


	xchg %rsp, %rax
//X8664:    	.bundle_lock
//X8664-NEXT: 	xchgl	%esp, %eax
//X8664-NEXT: 	leaq	(%rsp,%r15), %rsp
//X8664-NEXT: 	.bundle_unlock


	xchg (%rax), %rsp
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	.bundle_lock
//X8664-NEXT: 	xchgl	%esp, (%r15,%rax)
//X8664-NEXT: 	.bundle_unlock
//X8664-NEXT: 	leaq	(%rsp,%r15), %rsp
//X8664-NEXT: 	.bundle_unlock


	xchg %rsp, (%rax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	.bundle_lock
//X8664-NEXT: 	xchgl	%esp, (%r15,%rax)
//X8664-NEXT: 	.bundle_unlock
//X8664-NEXT: 	leaq	(%rsp,%r15), %rsp
//X8664-NEXT: 	.bundle_unlock


	xchg %rbp, %r11
//X8664:    	.bundle_lock
//X8664-NEXT: 	xchgl	%ebp, %r11d
//X8664-NEXT: 	leaq	(%rbp,%r15), %rbp
//X8664-NEXT: 	.bundle_unlock
	

	
