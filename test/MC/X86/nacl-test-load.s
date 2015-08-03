// RUN: llvm-mc -filetype asm -triple x86_64-unknown-nacl %s | FileCheck %s


.scratch %r11


	mov 12(%rsp), %rax
//CHECK:    	movq	12(%rsp), %rax

	mov 12(%rbp), %rax
//CHECK:    	movq	12(%rbp), %rax

	mov 12(%r15), %rax
//CHECK:    	movq	12(%r15), %rax

	mov 12(%rip), %rax
//CHECK:    	movq	12(%rip), %rax

	mov -12(,%rsp), %rax
//CHECK:    	movq	-12(%rsp), %rax

	mov -12(,%rbp), %rax
//CHECK:    	movq	-12(%rbp), %rax

	mov -12(,%r15), %rax
//CHECK:    	movq	-12(%r15), %rax

	mov -12(,%rip), %rax
//CHECK:    	movq	-12(%rip), %rax

	mov 131072(%rsp, %rdi, 8), %rax
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movq	131072(%rsp,%rdi,8), %rax
//CHECK-NEXT: 	.bundle_unlock

	mov 131072(%rbp, %rdi, 8), %rax
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movq	131072(%rbp,%rdi,8), %rax
//CHECK-NEXT: 	.bundle_unlock

	mov 131072(%r15, %rdi, 8), %rax
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movq	131072(%r15,%rdi,8), %rax
//CHECK-NEXT: 	.bundle_unlock

	mov 131072(%rip, %rdi, 8), %rax
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movq	131072(%rip,%rdi,8), %rax
//CHECK-NEXT: 	.bundle_unlock

	mov 131072(%rax), %rax
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%eax, %eax
//CHECK-NEXT: 	movq	131072(%r15,%rax), %rax
//CHECK-NEXT: 	.bundle_unlock

	mov 131072(,%rax), %rax
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(,%rax), %eax
//CHECK-NEXT: 	movq	(%r15,%rax), %rax
//CHECK-NEXT: 	.bundle_unlock

	mov 131072(%rax, %rdi, 8), %rax
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %eax
//CHECK-NEXT: 	movq	(%r15,%rax), %rax
//CHECK-NEXT: 	.bundle_unlock

	movl 12(%rsp), %eax
//CHECK:    	movl	12(%rsp), %eax

	movl 12(%rbp), %eax
//CHECK:    	movl	12(%rbp), %eax

	movl 12(%r15), %eax
//CHECK:    	movl	12(%r15), %eax

	movl 12(%rip), %eax
//CHECK:    	movl	12(%rip), %eax

	movl -12(,%rsp), %eax
//CHECK:    	movl	-12(%rsp), %eax

	movl -12(,%rbp), %eax
//CHECK:    	movl	-12(%rbp), %eax

	movl -12(,%r15), %eax
//CHECK:    	movl	-12(%r15), %eax

	movl -12(,%rip), %eax
//CHECK:    	movl	-12(%rip), %eax

	movl 131072(%rsp, %rdi, 8), %eax
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movl	131072(%rsp,%rdi,8), %eax
//CHECK-NEXT: 	.bundle_unlock

	movl 131072(%rbp, %rdi, 8), %eax
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movl	131072(%rbp,%rdi,8), %eax
//CHECK-NEXT: 	.bundle_unlock

	movl 131072(%r15, %rdi, 8), %eax
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movl	131072(%r15,%rdi,8), %eax
//CHECK-NEXT: 	.bundle_unlock

	movl 131072(%rip, %rdi, 8), %eax
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movl	131072(%rip,%rdi,8), %eax
//CHECK-NEXT: 	.bundle_unlock

	movl 131072(%rax), %eax
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%eax, %eax
//CHECK-NEXT: 	movl	131072(%r15,%rax), %eax
//CHECK-NEXT: 	.bundle_unlock

	movl 131072(,%rax), %eax
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(,%rax), %eax
//CHECK-NEXT: 	movl	(%r15,%rax), %eax
//CHECK-NEXT: 	.bundle_unlock

	movl 131072(%rax, %rdi, 8), %eax
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %eax
//CHECK-NEXT: 	movl	(%r15,%rax), %eax
//CHECK-NEXT: 	.bundle_unlock

	movw 12(%rsp), %ax
//CHECK:    	movw	12(%rsp), %ax

	movw 12(%rbp), %ax
//CHECK:    	movw	12(%rbp), %ax

	movw 12(%r15), %ax
//CHECK:    	movw	12(%r15), %ax

	movw 12(%rip), %ax
//CHECK:    	movw	12(%rip), %ax

	movw -12(,%rsp), %ax
//CHECK:    	movw	-12(%rsp), %ax

	movw -12(,%rbp), %ax
//CHECK:    	movw	-12(%rbp), %ax

	movw -12(,%r15), %ax
//CHECK:    	movw	-12(%r15), %ax

	movw -12(,%rip), %ax
//CHECK:    	movw	-12(%rip), %ax

	movw 131072(%rsp, %rdi, 8), %ax
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movw	131072(%rsp,%rdi,8), %ax
//CHECK-NEXT: 	.bundle_unlock

	movw 131072(%rbp, %rdi, 8), %ax
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movw	131072(%rbp,%rdi,8), %ax
//CHECK-NEXT: 	.bundle_unlock

	movw 131072(%r15, %rdi, 8), %ax
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movw	131072(%r15,%rdi,8), %ax
//CHECK-NEXT: 	.bundle_unlock

	movw 131072(%rip, %rdi, 8), %ax
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movw	131072(%rip,%rdi,8), %ax
//CHECK-NEXT: 	.bundle_unlock

	movw 131072(%rax), %ax
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%eax, %eax
//CHECK-NEXT: 	movw	131072(%r15,%rax), %ax
//CHECK-NEXT: 	.bundle_unlock

	movw 131072(,%rax), %ax
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(,%rax), %eax
//CHECK-NEXT: 	movw	(%r15,%rax), %ax
//CHECK-NEXT: 	.bundle_unlock

	movw 131072(%rax, %rdi, 8), %ax
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %eax
//CHECK-NEXT: 	movw	(%r15,%rax), %ax
//CHECK-NEXT: 	.bundle_unlock

	movb 12(%rsp), %ah
//CHECK:    	movb	12(%rsp), %ah

	movb 12(%rbp), %ah
//CHECK:    	movb	12(%rbp), %ah

	movb 12(%r15), %ah
//CHECK:    	movb	12(%r15), %ah

	movb 12(%rip), %ah
//CHECK:    	movb	12(%rip), %ah

	movb -12(,%rsp), %ah
//CHECK:    	movb	-12(%rsp), %ah

	movb -12(,%rbp), %ah
//CHECK:    	movb	-12(%rbp), %ah

	movb -12(,%r15), %ah
//CHECK:    	movb	-12(%r15), %ah

	movb -12(,%rip), %ah
//CHECK:    	movb	-12(%rip), %ah

	movb 131072(%rsp, %rdi, 8), %ah
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movb	131072(%rsp,%rdi,8), %ah
//CHECK-NEXT: 	.bundle_unlock

	movb 131072(%rbp, %rdi, 8), %ah
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movb	131072(%rbp,%rdi,8), %ah
//CHECK-NEXT: 	.bundle_unlock

	movb 131072(%r15, %rdi, 8), %ah
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movb	131072(%r15,%rdi,8), %ah
//CHECK-NEXT: 	.bundle_unlock

	movb 131072(%rip, %rdi, 8), %ah
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movb	131072(%rip,%rdi,8), %ah
//CHECK-NEXT: 	.bundle_unlock

	movb 131072(%rax), %ah
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%eax, %eax
//CHECK-NEXT: 	movb	131072(%r15,%rax), %ah
//CHECK-NEXT: 	.bundle_unlock

	movb 131072(,%rax), %ah
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(,%rax), %eax
//CHECK-NEXT: 	movb	(%r15,%rax), %ah
//CHECK-NEXT: 	.bundle_unlock

	movb 131072(%rax, %rdi, 8), %ah
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %eax
//CHECK-NEXT: 	movb	(%r15,%rax), %ah
//CHECK-NEXT: 	.bundle_unlock

	movb 12(%rsp), %al
//CHECK:    	movb	12(%rsp), %al

	movb 12(%rbp), %al
//CHECK:    	movb	12(%rbp), %al

	movb 12(%r15), %al
//CHECK:    	movb	12(%r15), %al

	movb 12(%rip), %al
//CHECK:    	movb	12(%rip), %al

	movb -12(,%rsp), %al
//CHECK:    	movb	-12(%rsp), %al

	movb -12(,%rbp), %al
//CHECK:    	movb	-12(%rbp), %al

	movb -12(,%r15), %al
//CHECK:    	movb	-12(%r15), %al

	movb -12(,%rip), %al
//CHECK:    	movb	-12(%rip), %al

	movb 131072(%rsp, %rdi, 8), %al
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movb	131072(%rsp,%rdi,8), %al
//CHECK-NEXT: 	.bundle_unlock

	movb 131072(%rbp, %rdi, 8), %al
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movb	131072(%rbp,%rdi,8), %al
//CHECK-NEXT: 	.bundle_unlock

	movb 131072(%r15, %rdi, 8), %al
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movb	131072(%r15,%rdi,8), %al
//CHECK-NEXT: 	.bundle_unlock

	movb 131072(%rip, %rdi, 8), %al
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movb	131072(%rip,%rdi,8), %al
//CHECK-NEXT: 	.bundle_unlock

	movb 131072(%rax), %al
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%eax, %eax
//CHECK-NEXT: 	movb	131072(%r15,%rax), %al
//CHECK-NEXT: 	.bundle_unlock

	movb 131072(,%rax), %al
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(,%rax), %eax
//CHECK-NEXT: 	movb	(%r15,%rax), %al
//CHECK-NEXT: 	.bundle_unlock

	movb 131072(%rax, %rdi, 8), %al
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %eax
//CHECK-NEXT: 	movb	(%r15,%rax), %al
//CHECK-NEXT: 	.bundle_unlock


	prefetch 12(%rsp)
//CHECK:    	prefetch	12(%rsp)

	prefetch 12(%rbp)
//CHECK:    	prefetch	12(%rbp)

	prefetch 12(%r15)
//CHECK:    	prefetch	12(%r15)

	prefetch 12(%rip)
//CHECK:    	prefetch	12(%rip)

	prefetch -12(,%rsp)
//CHECK:    	prefetch	-12(%rsp)

	prefetch -12(,%rbp)
//CHECK:    	prefetch	-12(%rbp)

	prefetch -12(,%r15)
//CHECK:    	prefetch	-12(%r15)

	prefetch -12(,%rip)
//CHECK:    	prefetch	-12(%rip)

	prefetch 131072(%rsp, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	prefetch	131072(%rsp,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	prefetch 131072(%rbp, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	prefetch	131072(%rbp,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	prefetch 131072(%r15, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	prefetch	131072(%r15,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	prefetch 131072(%rip, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	prefetch	131072(%rip,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	prefetch 131072(%rax)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%eax, %eax
//CHECK-NEXT: 	prefetch	131072(%r15,%rax)
//CHECK-NEXT: 	.bundle_unlock

	prefetch 131072(,%rax)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(,%rax), %r11d
//CHECK-NEXT: 	prefetch	(%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock

	prefetch 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	prefetch	(%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock


	
	
