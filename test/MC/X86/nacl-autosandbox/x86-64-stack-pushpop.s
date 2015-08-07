// RUN: llvm-mc -nacl-enable-auto-sandboxing -filetype asm -triple x86_64-unknown-nacl %s | FileCheck %s --check-prefix=X8664
.scratch %r11

	movq %rsp, %rbp
//X8664:    	movq	%rsp, %rbp

	movq %rbp, %rsp
//X8664:    	movq	%rbp, %rsp

	push $12
//X8664:    	pushq	$12

	push %rax
//X8664:    	pushq	%rax

	push %rsp
//X8664:    	pushq	%rsp

	push 12(%rsp)
//X8664:    	pushq	12(%rsp)

	push 131072(%rax, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	pushq	(%r15,%r11)
//X8664-NEXT: 	.bundle_unlock

	pop %r11
//X8664:    	popq	%r11

	pop 12(%rsp)
//X8664:    	popq	12(%rsp)

        .scratch %r11
	pop 131072(%rax, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	popq	(%r15,%r11)
//X8664-NEXT: 	.bundle_unlock
