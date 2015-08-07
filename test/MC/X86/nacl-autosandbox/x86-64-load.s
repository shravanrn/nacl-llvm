// RUN: llvm-mc -nacl-enable-auto-sandboxing -filetype asm -triple x86_64-unknown-nacl %s | FileCheck %s --check-prefix=X8664
.scratch %r11

	mov 12(%rsp), %rax
//X8664:    	movq	12(%rsp), %rax

	mov 12(%rbp), %rax
//X8664:    	movq	12(%rbp), %rax

	mov 12(%r15), %rax
//X8664:    	movq	12(%r15), %rax

	mov 12(%rip), %rax
//X8664:    	movq	12(%rip), %rax

	mov -12(,%rsp), %rax
//X8664:    	movq	-12(%rsp), %rax

	mov -12(,%rbp), %rax
//X8664:    	movq	-12(%rbp), %rax

	mov -12(,%r15), %rax
//X8664:    	movq	-12(%r15), %rax

	mov 131072(%rsp, %rdi, 8), %rax
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movq	131072(%rsp,%rdi,8), %rax
//X8664-NEXT: 	.bundle_unlock

	mov 131072(%rbp, %rdi, 8), %rax
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movq	131072(%rbp,%rdi,8), %rax
//X8664-NEXT: 	.bundle_unlock

	mov 131072(%r15, %rdi, 8), %rax
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movq	131072(%r15,%rdi,8), %rax
//X8664-NEXT: 	.bundle_unlock

	mov 131072(%rax), %rax
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movq	131072(%r15,%rax), %rax
//X8664-NEXT: 	.bundle_unlock

	mov 131072(,%rax), %rax
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %eax
//X8664-NEXT: 	movq	(%r15,%rax), %rax
//X8664-NEXT: 	.bundle_unlock

	mov 131072(%rax, %rdi, 8), %rax
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %eax
//X8664-NEXT: 	movq	(%r15,%rax), %rax
//X8664-NEXT: 	.bundle_unlock

	movl 12(%rsp), %eax
//X8664:    	movl	12(%rsp), %eax

	movl 12(%rbp), %eax
//X8664:    	movl	12(%rbp), %eax

	movl 12(%r15), %eax
//X8664:    	movl	12(%r15), %eax

	movl 12(%rip), %eax
//X8664:    	movl	12(%rip), %eax

	movl -12(,%rsp), %eax
//X8664:    	movl	-12(%rsp), %eax

	movl -12(,%rbp), %eax
//X8664:    	movl	-12(%rbp), %eax

	movl -12(,%r15), %eax
//X8664:    	movl	-12(%r15), %eax

	movl 131072(%rsp, %rdi, 8), %eax
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movl	131072(%rsp,%rdi,8), %eax
//X8664-NEXT: 	.bundle_unlock

	movl 131072(%rbp, %rdi, 8), %eax
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movl	131072(%rbp,%rdi,8), %eax
//X8664-NEXT: 	.bundle_unlock

	movl 131072(%r15, %rdi, 8), %eax
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movl	131072(%r15,%rdi,8), %eax
//X8664-NEXT: 	.bundle_unlock

	movl 131072(%rax), %eax
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movl	131072(%r15,%rax), %eax
//X8664-NEXT: 	.bundle_unlock

	movl 131072(,%rax), %eax
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %eax
//X8664-NEXT: 	movl	(%r15,%rax), %eax
//X8664-NEXT: 	.bundle_unlock

	movl 131072(%rax, %rdi, 8), %eax
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %eax
//X8664-NEXT: 	movl	(%r15,%rax), %eax
//X8664-NEXT: 	.bundle_unlock

	movw 12(%rsp), %ax
//X8664:    	movw	12(%rsp), %ax

	movw 12(%rbp), %ax
//X8664:    	movw	12(%rbp), %ax

	movw 12(%r15), %ax
//X8664:    	movw	12(%r15), %ax

	movw 12(%rip), %ax
//X8664:    	movw	12(%rip), %ax

	movw -12(,%rsp), %ax
//X8664:    	movw	-12(%rsp), %ax

	movw -12(,%rbp), %ax
//X8664:    	movw	-12(%rbp), %ax

	movw -12(,%r15), %ax
//X8664:    	movw	-12(%r15), %ax

	movw 131072(%rsp, %rdi, 8), %ax
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movw	131072(%rsp,%rdi,8), %ax
//X8664-NEXT: 	.bundle_unlock

	movw 131072(%rbp, %rdi, 8), %ax
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movw	131072(%rbp,%rdi,8), %ax
//X8664-NEXT: 	.bundle_unlock

	movw 131072(%r15, %rdi, 8), %ax
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movw	131072(%r15,%rdi,8), %ax
//X8664-NEXT: 	.bundle_unlock

	movw 131072(%rax), %ax
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movw	131072(%r15,%rax), %ax
//X8664-NEXT: 	.bundle_unlock

	movw 131072(,%rax), %ax
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %eax
//X8664-NEXT: 	movw	(%r15,%rax), %ax
//X8664-NEXT: 	.bundle_unlock

	movw 131072(%rax, %rdi, 8), %ax
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %eax
//X8664-NEXT: 	movw	(%r15,%rax), %ax
//X8664-NEXT: 	.bundle_unlock

	movb 12(%rsp), %ah
//X8664:    	movb	12(%rsp), %ah

	movb 12(%rbp), %ah
//X8664:    	movb	12(%rbp), %ah

	movb 12(%r15), %ah
//X8664:    	movb	12(%r15), %ah

	movb 12(%rip), %ah
//X8664:    	movb	12(%rip), %ah

	movb -12(,%rsp), %ah
//X8664:    	movb	-12(%rsp), %ah

	movb -12(,%rbp), %ah
//X8664:    	movb	-12(%rbp), %ah

	movb -12(,%r15), %ah
//X8664:    	movb	-12(%r15), %ah

	movb 131072(%rsp, %rdi, 8), %ah
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movb	131072(%rsp,%rdi,8), %ah
//X8664-NEXT: 	.bundle_unlock

	movb 131072(%rbp, %rdi, 8), %ah
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movb	131072(%rbp,%rdi,8), %ah
//X8664-NEXT: 	.bundle_unlock

	movb 131072(%r15, %rdi, 8), %ah
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movb	131072(%r15,%rdi,8), %ah
//X8664-NEXT: 	.bundle_unlock

	movb 131072(%rax), %ah
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movb	131072(%r15,%rax), %ah
//X8664-NEXT: 	.bundle_unlock

	movb 131072(,%rax), %ah
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %eax
//X8664-NEXT: 	movb	(%r15,%rax), %ah
//X8664-NEXT: 	.bundle_unlock

	movb 131072(%rax, %rdi, 8), %ah
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %eax
//X8664-NEXT: 	movb	(%r15,%rax), %ah
//X8664-NEXT: 	.bundle_unlock

	movb 12(%rsp), %al
//X8664:    	movb	12(%rsp), %al

	movb 12(%rbp), %al
//X8664:    	movb	12(%rbp), %al

	movb 12(%r15), %al
//X8664:    	movb	12(%r15), %al

	movb 12(%rip), %al
//X8664:    	movb	12(%rip), %al

	movb -12(,%rsp), %al
//X8664:    	movb	-12(%rsp), %al

	movb -12(,%rbp), %al
//X8664:    	movb	-12(%rbp), %al

	movb -12(,%r15), %al
//X8664:    	movb	-12(%r15), %al

	movb 131072(%rsp, %rdi, 8), %al
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movb	131072(%rsp,%rdi,8), %al
//X8664-NEXT: 	.bundle_unlock

	movb 131072(%rbp, %rdi, 8), %al
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movb	131072(%rbp,%rdi,8), %al
//X8664-NEXT: 	.bundle_unlock

	movb 131072(%r15, %rdi, 8), %al
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movb	131072(%r15,%rdi,8), %al
//X8664-NEXT: 	.bundle_unlock

	movb 131072(%rax), %al
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movb	131072(%r15,%rax), %al
//X8664-NEXT: 	.bundle_unlock

	movb 131072(,%rax), %al
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %eax
//X8664-NEXT: 	movb	(%r15,%rax), %al
//X8664-NEXT: 	.bundle_unlock

	movb 131072(%rax, %rdi, 8), %al
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %eax
//X8664-NEXT: 	movb	(%r15,%rax), %al
//X8664-NEXT: 	.bundle_unlock


	prefetch 12(%rsp)
//X8664:    	prefetch	12(%rsp)

	prefetch 12(%rbp)
//X8664:    	prefetch	12(%rbp)

	prefetch 12(%r15)
//X8664:    	prefetch	12(%r15)

	prefetch 12(%rip)
//X8664:    	prefetch	12(%rip)

	prefetch -12(,%rsp)
//X8664:    	prefetch	-12(%rsp)

	prefetch -12(,%rbp)
//X8664:    	prefetch	-12(%rbp)

	prefetch -12(,%r15)
//X8664:    	prefetch	-12(%r15)

	prefetch 131072(%rsp, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	prefetch	131072(%rsp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	prefetch 131072(%rbp, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	prefetch	131072(%rbp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	prefetch 131072(%r15, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	prefetch	131072(%r15,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	prefetch 131072(%rax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	prefetch	131072(%r15,%rax)
//X8664-NEXT: 	.bundle_unlock

	prefetch 131072(,%rax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %r11d
//X8664-NEXT: 	prefetch	(%r15,%r11)
//X8664-NEXT: 	.bundle_unlock

	prefetch 131072(%rax, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	prefetch	(%r15,%r11)
//X8664-NEXT: 	.bundle_unlock


	
	
