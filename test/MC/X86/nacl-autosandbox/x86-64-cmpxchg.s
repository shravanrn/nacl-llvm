// RUN: llvm-mc -filetype asm -triple x86_64-unknown-nacl %s | FileCheck %s --check-prefix=X8664 --check-prefix=X64
.scratch %r11

	cmpxchg %rbx, %rdx
//X8664:    	cmpxchgq	%rbx, %rdx

	cmpxchg %rax, 12(%rsp)
//X8664:    	cmpxchgq	%rax, 12(%rsp)

	cmpxchg %rax, 131072(%rax, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	cmpxchgq	%rax, (%r15,%r11)
//X8664-NEXT: 	.bundle_unlock

	cmpxchg %rcx, 12(%rsp)
//X8664:    	cmpxchgq	%rcx, 12(%rsp)

	cmpxchg %rcx, 131072(%rax, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	cmpxchgq	%rcx, (%r15,%r11)
//X8664-NEXT: 	.bundle_unlock


	xchg %rax, %rbx
//X8664:    	xchgq	%rbx, %rax

	xchg %rbx, %rdx
//X8664:    	xchgq	%rbx, %rdx

	xchg %rax, 12(%rsp)
//X8664:    	xchgq	%rax, 12(%rsp)

	xchg %rax, 131072(%rax, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	xchgq	%rax, (%r15,%r11)
//X8664-NEXT: 	.bundle_unlock

	xchg %rdx, 12(%rsp)
//X8664:    	xchgq	%rdx, 12(%rsp)

	xchg %rdx, 131072(%rax, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	xchgq	%rdx, (%r15,%r11)
//X8664-NEXT: 	.bundle_unlock
