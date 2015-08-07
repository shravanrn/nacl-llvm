// RUN: llvm-mc -nacl-enable-auto-sandboxing -filetype asm -triple i686-unknown-nacl %s | FileCheck %s --check-prefix=X8632
// RUN: llvm-mc -nacl-enable-auto-sandboxing -filetype asm -triple x86_64-unknown-nacl %s | FileCheck %s --check-prefix=X8664
.scratch %ecx


	movl 12(%esp), %eax
//X8632:    	movl	12(%esp), %eax
//X8664:    	movl	12(%rsp), %eax

	movl 12(%ebp), %eax
//X8632:    	movl	12(%ebp), %eax
//X8664:    	movl	12(%rbp), %eax

	movl 12(%eip), %eax
//X8632:    	movl	12(%eip), %eax
//X8664:    	movl	12(%rip), %eax

	movl -12(,%esp), %eax
//X8632:    	movl	-12(,%esp), %eax
//X8664:    	movl	-12(%rsp), %eax

	movl -12(,%ebp), %eax
//X8632:    	movl	-12(,%ebp), %eax
//X8664:    	movl	-12(%rbp), %eax

	movl 131072(%esp, %edi, 8), %eax
//X8632:    	movl	131072(%esp,%edi,8), %eax
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movl	131072(%rsp,%rdi,8), %eax
//X8664-NEXT: 	.bundle_unlock

	movl 131072(%ebp, %edi, 8), %eax
//X8632:    	movl	131072(%ebp,%edi,8), %eax
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movl	131072(%rbp,%rdi,8), %eax
//X8664-NEXT: 	.bundle_unlock

	movl 131072(%eax), %eax
//X8632:    	movl	131072(%eax), %eax
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movl	131072(%r15,%rax), %eax
//X8664-NEXT: 	.bundle_unlock

	movl 131072(,%eax), %eax
//X8632:    	movl	131072(,%eax), %eax
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %eax
//X8664-NEXT: 	movl	(%r15,%rax), %eax
//X8664-NEXT: 	.bundle_unlock

	movl 131072(%eax, %edi, 8), %eax
//X8632:    	movl	131072(%eax,%edi,8), %eax
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %eax
//X8664-NEXT: 	movl	(%r15,%rax), %eax
//X8664-NEXT: 	.bundle_unlock

	movw 12(%esp), %ax
//X8632:    	movw	12(%esp), %ax
//X8664:    	movw	12(%rsp), %ax

	movw 12(%ebp), %ax
//X8632:    	movw	12(%ebp), %ax
//X8664:    	movw	12(%rbp), %ax

	movw 12(%eip), %ax
//X8632:    	movw	12(%eip), %ax
//X8664:    	movw	12(%rip), %ax

	movw -12(,%esp), %ax
//X8632:    	movw	-12(,%esp), %ax
//X8664:    	movw	-12(%rsp), %ax

	movw -12(,%ebp), %ax
//X8632:    	movw	-12(,%ebp), %ax
//X8664:    	movw	-12(%rbp), %ax

	movw 131072(%esp, %edi, 8), %ax
//X8632:    	movw	131072(%esp,%edi,8), %ax
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movw	131072(%rsp,%rdi,8), %ax
//X8664-NEXT: 	.bundle_unlock

	movw 131072(%ebp, %edi, 8), %ax
//X8632:    	movw	131072(%ebp,%edi,8), %ax
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movw	131072(%rbp,%rdi,8), %ax
//X8664-NEXT: 	.bundle_unlock

	movw 131072(%eax), %ax
//X8632:    	movw	131072(%eax), %ax
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movw	131072(%r15,%rax), %ax
//X8664-NEXT: 	.bundle_unlock

	movw 131072(,%eax), %ax
//X8632:    	movw	131072(,%eax), %ax
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %eax
//X8664-NEXT: 	movw	(%r15,%rax), %ax
//X8664-NEXT: 	.bundle_unlock

	movw 131072(%eax, %edi, 8), %ax
//X8632:    	movw	131072(%eax,%edi,8), %ax
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %eax
//X8664-NEXT: 	movw	(%r15,%rax), %ax
//X8664-NEXT: 	.bundle_unlock

	movb 12(%esp), %ah
//X8632:    	movb	12(%esp), %ah
//X8664:    	movb	12(%rsp), %ah

	movb 12(%ebp), %ah
//X8632:    	movb	12(%ebp), %ah
//X8664:    	movb	12(%rbp), %ah

	movb 12(%eip), %ah
//X8632:    	movb	12(%eip), %ah
//X8664:    	movb	12(%rip), %ah

	movb -12(,%esp), %ah
//X8632:    	movb	-12(,%esp), %ah
//X8664:    	movb	-12(%rsp), %ah

	movb -12(,%ebp), %ah
//X8632:    	movb	-12(,%ebp), %ah
//X8664:    	movb	-12(%rbp), %ah

	movb 131072(%esp, %edi, 8), %ah
//X8632:    	movb	131072(%esp,%edi,8), %ah
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movb	131072(%rsp,%rdi,8), %ah
//X8664-NEXT: 	.bundle_unlock

	movb 131072(%ebp, %edi, 8), %ah
//X8632:    	movb	131072(%ebp,%edi,8), %ah
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movb	131072(%rbp,%rdi,8), %ah
//X8664-NEXT: 	.bundle_unlock

	movb 131072(%eax), %ah
//X8632:    	movb	131072(%eax), %ah
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movb	131072(%r15,%rax), %ah
//X8664-NEXT: 	.bundle_unlock

	movb 131072(,%eax), %ah
//X8632:    	movb	131072(,%eax), %ah
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %eax
//X8664-NEXT: 	movb	(%r15,%rax), %ah
//X8664-NEXT: 	.bundle_unlock

	movb 131072(%eax, %edi, 8), %ah
//X8632:    	movb	131072(%eax,%edi,8), %ah
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %eax
//X8664-NEXT: 	movb	(%r15,%rax), %ah
//X8664-NEXT: 	.bundle_unlock

	movb 12(%esp), %al
//X8632:    	movb	12(%esp), %al
//X8664:    	movb	12(%rsp), %al

	movb 12(%ebp), %al
//X8632:    	movb	12(%ebp), %al
//X8664:    	movb	12(%rbp), %al

	movb 12(%eip), %al
//X8632:    	movb	12(%eip), %al
//X8664:    	movb	12(%rip), %al

	movb -12(,%esp), %al
//X8632:    	movb	-12(,%esp), %al
//X8664:    	movb	-12(%rsp), %al

	movb -12(,%ebp), %al
//X8632:    	movb	-12(,%ebp), %al
//X8664:    	movb	-12(%rbp), %al

	movb 131072(%esp, %edi, 8), %al
//X8632:    	movb	131072(%esp,%edi,8), %al
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movb	131072(%rsp,%rdi,8), %al
//X8664-NEXT: 	.bundle_unlock

	movb 131072(%ebp, %edi, 8), %al
//X8632:    	movb	131072(%ebp,%edi,8), %al
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movb	131072(%rbp,%rdi,8), %al
//X8664-NEXT: 	.bundle_unlock

	movb 131072(%eax), %al
//X8632:    	movb	131072(%eax), %al
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movb	131072(%r15,%rax), %al
//X8664-NEXT: 	.bundle_unlock

	movb 131072(,%eax), %al
//X8632:    	movb	131072(,%eax), %al
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %eax
//X8664-NEXT: 	movb	(%r15,%rax), %al
//X8664-NEXT: 	.bundle_unlock

	movb 131072(%eax, %edi, 8), %al
//X8632:    	movb	131072(%eax,%edi,8), %al
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %eax
//X8664-NEXT: 	movb	(%r15,%rax), %al
//X8664-NEXT: 	.bundle_unlock


	prefetch 12(%esp)
//X8632:    	prefetch	12(%esp)
//X8664:    	prefetch	12(%rsp)

	prefetch 12(%ebp)
//X8632:    	prefetch	12(%ebp)
//X8664:    	prefetch	12(%rbp)

	prefetch 12(%eip)
//X8632:    	prefetch	12(%eip)
//X8664:    	prefetch	12(%rip)

	prefetch -12(,%esp)
//X8632:    	prefetch	-12(,%esp)
//X8664:    	prefetch	-12(%rsp)

	prefetch -12(,%ebp)
//X8632:    	prefetch	-12(,%ebp)
//X8664:    	prefetch	-12(%rbp)

	prefetch 131072(%esp, %edi, 8)
//X8632:    	prefetch	131072(%esp,%edi,8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	prefetch	131072(%rsp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	prefetch 131072(%ebp, %edi, 8)
//X8632:    	prefetch	131072(%ebp,%edi,8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	prefetch	131072(%rbp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	prefetch 131072(%eax)
//X8632:    	prefetch	131072(%eax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	prefetch	131072(%r15,%rax)
//X8664-NEXT: 	.bundle_unlock

	prefetch 131072(,%eax)
//X8632:    	prefetch	131072(,%eax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %ecx
//X8664-NEXT: 	prefetch	(%r15,%rcx)
//X8664-NEXT: 	.bundle_unlock

	prefetch 131072(%eax, %edi, 8)
//X8632:    	prefetch	131072(%eax,%edi,8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %ecx
//X8664-NEXT: 	prefetch	(%r15,%rcx)
//X8664-NEXT: 	.bundle_unlock
