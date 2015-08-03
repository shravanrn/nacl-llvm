// RUN: llvm-mc -filetype asm -triple x86_64-unknown-nacl %s | FileCheck %s

.scratch %r11


	cmpxchg %rax, 12(%rsp)
//CHECK:    	cmpxchgq	%rax, 12(%rsp)

	cmpxchg %rax, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	cmpxchgq	%rax, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock
	

	cmpxchg %rcx, 12(%rsp)
//CHECK:    	cmpxchgq	%rcx, 12(%rsp)

	cmpxchg %rcx, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	cmpxchgq	%rcx, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock
