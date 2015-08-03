// RUN: llvm-mc -filetype asm -triple x86_64-unknown-nacl %s | FileCheck %s

.scratch %r11

// Test different size operands

	add 12(%rsp), %rax
//CHECK:    	addq	12(%rsp), %rax

	add 131072(%rax, %rdi, 8), %rax
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	addq	(%r15,%r11), %rax
//CHECK-NEXT: 	.bundle_unlock

	add %rax, 12(%rsp)
//CHECK:    	addq	%rax, 12(%rsp)

	add %rax, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	addq	%rax, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock
	

	add 12(%rsp), %eax
//CHECK:    	addl	12(%rsp), %eax

	add 131072(%rax, %rdi, 8), %eax
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	addl	(%r15,%r11), %eax
//CHECK-NEXT: 	.bundle_unlock

	add %eax, 12(%rsp)
//CHECK:    	addl	%eax, 12(%rsp)

	add %eax, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	addl	%eax, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock


	add 12(%rsp), %ax
//CHECK:    	addw	12(%rsp), %ax

	add 131072(%rax, %rdi, 8), %ax
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	addw	(%r15,%r11), %ax
//CHECK-NEXT: 	.bundle_unlock

	add %ax, 12(%rsp)
//CHECK:    	addw	%ax, 12(%rsp)

	add %ax, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	addw	%ax, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock


	add 12(%rsp), %ah
//CHECK:    	addb	12(%rsp), %ah

	add 131072(%rax, %rdi, 8), %ah
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	addb	(%r15,%r11), %ah
//CHECK-NEXT: 	.bundle_unlock

	add %ah, 12(%rsp)
//CHECK:    	addb	%ah, 12(%rsp)

	add %ah, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	addb	%ah, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock


	add 12(%rsp), %al
//CHECK:    	addb	12(%rsp), %al

	add 131072(%rax, %rdi, 8), %al
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	addb	(%r15,%r11), %al
//CHECK-NEXT: 	.bundle_unlock

	add %al, 12(%rsp)
//CHECK:    	addb	%al, 12(%rsp)

	add %al, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	addb	%al, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock
	
// Test various integer/logic operations


	leaq (%rax, %rbx), %rcx
//CHECK:    	leaq	(%rax,%rbx), %rcx


	add $12, %rax
//CHECK:    	addq	$12, %rax

	addq $12, 12(%rsp)
//CHECK:    	addq	$12, 12(%rsp)

	addq $12, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	addq	$12, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock

	add %rax, %rbx
//CHECK:    	addq	%rax, %rbx

	add %rax, 12(%rsp)
//CHECK:    	addq	%rax, 12(%rsp)

	add %rax, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	addq	%rax, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock

	add 12(%rsp), %rax
//CHECK:    	addq	12(%rsp), %rax

	add 131072(%rax, %rdi, 8), %rax
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	addq	(%r15,%r11), %rax
//CHECK-NEXT: 	.bundle_unlock


	sub $12, %rax
//CHECK:    	subq	$12, %rax

	subq $12, 12(%rsp)
//CHECK:    	subq	$12, 12(%rsp)

	subq $12, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	subq	$12, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock

	sub %rax, %rbx
//CHECK:    	subq	%rax, %rbx

	sub %rax, 12(%rsp)
//CHECK:    	subq	%rax, 12(%rsp)

	sub %rax, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	subq	%rax, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock

	sub 12(%rsp), %rax
//CHECK:    	subq	12(%rsp), %rax

	sub 131072(%rax, %rdi, 8), %rax
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	subq	(%r15,%r11), %rax
//CHECK-NEXT: 	.bundle_unlock


	imulq $12, %rax
//CHECK:    	imulq	$12, %rax, %rax

	imulq %rax, %rbx
//CHECK:    	imulq	%rax, %rbx

	imulq 12(%rsp), %rax
//CHECK:    	imulq	12(%rsp), %rax

	imulq 131072(%rax, %rdi, 8), %rax
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	imulq	(%r15,%r11), %rax
//CHECK-NEXT: 	.bundle_unlock
	

	inc %rax
//CHECK:    	incq	%rax

	incq 12(%rsp)
//CHECK:    	incq	12(%rsp)

	incq 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	incq	(%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock


	dec %rax
//CHECK:    	decq	%rax

	decq 12(%rsp)
//CHECK:    	decq	12(%rsp)

	decq 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	decq	(%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock


	neg %rax
//CHECK:    	negq	%rax

	negq 12(%rsp)
//CHECK:    	negq	12(%rsp)

	negq 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	negq	(%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock


	not %rax
//CHECK:    	notq	%rax

	notq 12(%rsp)
//CHECK:    	notq	12(%rsp)

	notq 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	notq	(%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock


	salq $7, %rax
//CHECK:    	shlq	$7, %rax

	salq $7, 12(%rsp)
//CHECK:    	shlq	$7, 12(%rsp)

	salq $7, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	shlq	$7, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock


	shlq $7, %rax
//CHECK:    	shlq	$7, %rax

	salq $7, 12(%rsp)
//CHECK:    	shlq	$7, 12(%rsp)

	salq $7, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	shlq	$7, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock

	
