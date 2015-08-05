// RUN: llvm-mc -filetype asm -triple x86_64-unknown-nacl %s | FileCheck %s --check-prefix=X8664
.scratch %r11

	movq $12, 12(%rsp)
//X8664:    	movq	$12, 12(%rsp)

	movq $12, 12(%rbp)
//X8664:    	movq	$12, 12(%rbp)

	movq $12, 12(%r15)
//X8664:    	movq	$12, 12(%r15)

	movq $12, 12(%rip)
//X8664:    	movq	$12, 12(%rip)

	movq $12, -12(,%rsp)
//X8664:    	movq	$12, -12(%rsp)

	movq $12, -12(,%rbp)
//X8664:    	movq	$12, -12(%rbp)

	movq $12, -12(,%r15)
//X8664:    	movq	$12, -12(%r15)

	movq $12, 131072(%rsp, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movq	$12, 131072(%rsp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movq $12, 131072(%rbp, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movq	$12, 131072(%rbp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movq $12, 131072(%r15, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movq	$12, 131072(%r15,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movq $12, 131072(%rax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movq	$12, 131072(%r15,%rax)
//X8664-NEXT: 	.bundle_unlock

	movq $12, 131072(,%rax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %r11d
//X8664-NEXT: 	movq	$12, (%r15,%r11)
//X8664-NEXT: 	.bundle_unlock

	movq $12, 131072(%rax, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	movq	$12, (%r15,%r11)
//X8664-NEXT: 	.bundle_unlock

	movq $131072, 12(%rsp)
//X8664:    	movq	$131072, 12(%rsp)       

	movq $131072, 12(%rbp)
//X8664:    	movq	$131072, 12(%rbp)       

	movq $131072, 12(%r15)
//X8664:    	movq	$131072, 12(%r15)       

	movq $131072, 12(%rip)
//X8664:    	movq	$131072, 12(%rip)       

	movq $131072, -12(,%rsp)
//X8664:    	movq	$131072, -12(%rsp)      

	movq $131072, -12(,%rbp)
//X8664:    	movq	$131072, -12(%rbp)      

	movq $131072, -12(,%r15)
//X8664:    	movq	$131072, -12(%r15)      

	movq $131072, 131072(%rsp, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movq	$131072, 131072(%rsp,%rdi,8) 
//X8664-NEXT: 	.bundle_unlock

	movq $131072, 131072(%rbp, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movq	$131072, 131072(%rbp,%rdi,8) 
//X8664-NEXT: 	.bundle_unlock

	movq $131072, 131072(%r15, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movq	$131072, 131072(%r15,%rdi,8) 
//X8664-NEXT: 	.bundle_unlock

	movq $131072, 131072(%rax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movq	$131072, 131072(%r15,%rax) 
//X8664-NEXT: 	.bundle_unlock

	movq $131072, 131072(,%rax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %r11d
//X8664-NEXT: 	movq	$131072, (%r15,%r11)    
//X8664-NEXT: 	.bundle_unlock

	movq $131072, 131072(%rax, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	movq	$131072, (%r15,%r11)    
//X8664-NEXT: 	.bundle_unlock

	movl $12, 12(%rsp)
//X8664:    	movl	$12, 12(%rsp)

	movl $12, 12(%rbp)
//X8664:    	movl	$12, 12(%rbp)

	movl $12, 12(%r15)
//X8664:    	movl	$12, 12(%r15)

	movl $12, 12(%rip)
//X8664:    	movl	$12, 12(%rip)

	movl $12, -12(,%rsp)
//X8664:    	movl	$12, -12(%rsp)

	movl $12, -12(,%rbp)
//X8664:    	movl	$12, -12(%rbp)

	movl $12, -12(,%r15)
//X8664:    	movl	$12, -12(%r15)

	movl $12, 131072(%rsp, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movl	$12, 131072(%rsp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movl $12, 131072(%rbp, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movl	$12, 131072(%rbp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movl $12, 131072(%r15, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movl	$12, 131072(%r15,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movl $12, 131072(%rax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movl	$12, 131072(%r15,%rax)
//X8664-NEXT: 	.bundle_unlock

	movl $12, 131072(,%rax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %r11d
//X8664-NEXT: 	movl	$12, (%r15,%r11)
//X8664-NEXT: 	.bundle_unlock

	movl $12, 131072(%rax, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	movl	$12, (%r15,%r11)
//X8664-NEXT: 	.bundle_unlock

	movl $131072, 12(%rsp)
//X8664:    	movl	$131072, 12(%rsp)       

	movl $131072, 12(%rbp)
//X8664:    	movl	$131072, 12(%rbp)       

	movl $131072, 12(%r15)
//X8664:    	movl	$131072, 12(%r15)       

	movl $131072, 12(%rip)
//X8664:    	movl	$131072, 12(%rip)       

	movl $131072, -12(,%rsp)
//X8664:    	movl	$131072, -12(%rsp)      

	movl $131072, -12(,%rbp)
//X8664:    	movl	$131072, -12(%rbp)      

	movl $131072, -12(,%r15)
//X8664:    	movl	$131072, -12(%r15)      

	movl $131072, 131072(%rsp, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movl	$131072, 131072(%rsp,%rdi,8) 
//X8664-NEXT: 	.bundle_unlock

	movl $131072, 131072(%rbp, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movl	$131072, 131072(%rbp,%rdi,8) 
//X8664-NEXT: 	.bundle_unlock

	movl $131072, 131072(%r15, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movl	$131072, 131072(%r15,%rdi,8) 
//X8664-NEXT: 	.bundle_unlock

	movl $131072, 131072(%rax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movl	$131072, 131072(%r15,%rax) 
//X8664-NEXT: 	.bundle_unlock

	movl $131072, 131072(,%rax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %r11d
//X8664-NEXT: 	movl	$131072, (%r15,%r11)    
//X8664-NEXT: 	.bundle_unlock

	movl $131072, 131072(%rax, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	movl	$131072, (%r15,%r11)    
//X8664-NEXT: 	.bundle_unlock

	movw $12, 12(%rsp)
//X8664:    	movw	$12, 12(%rsp)

	movw $12, 12(%rbp)
//X8664:    	movw	$12, 12(%rbp)

	movw $12, 12(%r15)
//X8664:    	movw	$12, 12(%r15)

	movw $12, 12(%rip)
//X8664:    	movw	$12, 12(%rip)

	movw $12, -12(,%rsp)
//X8664:    	movw	$12, -12(%rsp)

	movw $12, -12(,%rbp)
//X8664:    	movw	$12, -12(%rbp)

	movw $12, -12(,%r15)
//X8664:    	movw	$12, -12(%r15)

	movw $12, 131072(%rsp, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movw	$12, 131072(%rsp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movw $12, 131072(%rbp, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movw	$12, 131072(%rbp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movw $12, 131072(%r15, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movw	$12, 131072(%r15,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movw $12, 131072(%rax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movw	$12, 131072(%r15,%rax)
//X8664-NEXT: 	.bundle_unlock

	movw $12, 131072(,%rax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %r11d
//X8664-NEXT: 	movw	$12, (%r15,%r11)
//X8664-NEXT: 	.bundle_unlock

	movw $12, 131072(%rax, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	movw	$12, (%r15,%r11)
//X8664-NEXT: 	.bundle_unlock

	movw $131072, 12(%rsp)
//X8664:    	movw	$131072, 12(%rsp)       

	movw $131072, 12(%rbp)
//X8664:    	movw	$131072, 12(%rbp)       

	movw $131072, 12(%r15)
//X8664:    	movw	$131072, 12(%r15)       

	movw $131072, 12(%rip)
//X8664:    	movw	$131072, 12(%rip)       

	movw $131072, -12(,%rsp)
//X8664:    	movw	$131072, -12(%rsp)      

	movw $131072, -12(,%rbp)
//X8664:    	movw	$131072, -12(%rbp)      

	movw $131072, -12(,%r15)
//X8664:    	movw	$131072, -12(%r15)      

	movw $131072, 131072(%rsp, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movw	$131072, 131072(%rsp,%rdi,8) 
//X8664-NEXT: 	.bundle_unlock

	movw $131072, 131072(%rbp, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movw	$131072, 131072(%rbp,%rdi,8) 
//X8664-NEXT: 	.bundle_unlock

	movw $131072, 131072(%r15, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movw	$131072, 131072(%r15,%rdi,8) 
//X8664-NEXT: 	.bundle_unlock

	movw $131072, 131072(%rax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movw	$131072, 131072(%r15,%rax) 
//X8664-NEXT: 	.bundle_unlock

	movw $131072, 131072(,%rax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %r11d
//X8664-NEXT: 	movw	$131072, (%r15,%r11)    
//X8664-NEXT: 	.bundle_unlock

	movw $131072, 131072(%rax, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	movw	$131072, (%r15,%r11)    
//X8664-NEXT: 	.bundle_unlock

	movb $12, 12(%rsp)
//X8664:    	movb	$12, 12(%rsp)

	movb $12, 12(%rbp)
//X8664:    	movb	$12, 12(%rbp)

	movb $12, 12(%r15)
//X8664:    	movb	$12, 12(%r15)

	movb $12, 12(%rip)
//X8664:    	movb	$12, 12(%rip)

	movb $12, -12(,%rsp)
//X8664:    	movb	$12, -12(%rsp)

	movb $12, -12(,%rbp)
//X8664:    	movb	$12, -12(%rbp)

	movb $12, -12(,%r15)
//X8664:    	movb	$12, -12(%r15)

	movb $12, 131072(%rsp, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movb	$12, 131072(%rsp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movb $12, 131072(%rbp, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movb	$12, 131072(%rbp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movb $12, 131072(%r15, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movb	$12, 131072(%r15,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movb $12, 131072(%rax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movb	$12, 131072(%r15,%rax)
//X8664-NEXT: 	.bundle_unlock

	movb $12, 131072(,%rax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %r11d
//X8664-NEXT: 	movb	$12, (%r15,%r11)
//X8664-NEXT: 	.bundle_unlock

	movb $12, 131072(%rax, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	movb	$12, (%r15,%r11)
//X8664-NEXT: 	.bundle_unlock

	movb $131072, 12(%rsp)
//X8664:    	movb	$131072, 12(%rsp)       

	movb $131072, 12(%rbp)
//X8664:    	movb	$131072, 12(%rbp)       

	movb $131072, 12(%r15)
//X8664:    	movb	$131072, 12(%r15)       

	movb $131072, 12(%rip)
//X8664:    	movb	$131072, 12(%rip)       

	movb $131072, -12(,%rsp)
//X8664:    	movb	$131072, -12(%rsp)      

	movb $131072, -12(,%rbp)
//X8664:    	movb	$131072, -12(%rbp)      

	movb $131072, -12(,%r15)
//X8664:    	movb	$131072, -12(%r15)      

	movb $131072, 131072(%rsp, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movb	$131072, 131072(%rsp,%rdi,8) 
//X8664-NEXT: 	.bundle_unlock

	movb $131072, 131072(%rbp, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movb	$131072, 131072(%rbp,%rdi,8) 
//X8664-NEXT: 	.bundle_unlock

	movb $131072, 131072(%r15, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movb	$131072, 131072(%r15,%rdi,8) 
//X8664-NEXT: 	.bundle_unlock

	movb $131072, 131072(%rax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movb	$131072, 131072(%r15,%rax) 
//X8664-NEXT: 	.bundle_unlock

	movb $131072, 131072(,%rax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %r11d
//X8664-NEXT: 	movb	$131072, (%r15,%r11)    
//X8664-NEXT: 	.bundle_unlock

	movb $131072, 131072(%rax, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	movb	$131072, (%r15,%r11)    
//X8664-NEXT: 	.bundle_unlock
	

	movq %rax, 12(%rsp)
//X8664:    	movq	%rax, 12(%rsp)

	movq %rax, 12(%rbp)
//X8664:    	movq	%rax, 12(%rbp)

	movq %rax, 12(%r15)
//X8664:    	movq	%rax, 12(%r15)

	movq %rax, 12(%rip)
//X8664:    	movq	%rax, 12(%rip)

	movq %rax, -12(,%rsp)
//X8664:    	movq	%rax, -12(%rsp)

	movq %rax, -12(,%rbp)
//X8664:    	movq	%rax, -12(%rbp)

	movq %rax, -12(,%r15)
//X8664:    	movq	%rax, -12(%r15)

	movq %rax, 131072(%rsp, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movq	%rax, 131072(%rsp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movq %rax, 131072(%rbp, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movq	%rax, 131072(%rbp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movq %rax, 131072(%r15, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movq	%rax, 131072(%r15,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movq %rax, 131072(%rax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movq	%rax, 131072(%r15,%rax)
//X8664-NEXT: 	.bundle_unlock

	movq %rax, 131072(,%rax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %r11d
//X8664-NEXT: 	movq	%rax, (%r15,%r11)
//X8664-NEXT: 	.bundle_unlock

	movq %rax, 131072(%rax, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	movq	%rax, (%r15,%r11)
//X8664-NEXT: 	.bundle_unlock

	movl %eax, 12(%rsp)
//X8664:    	movl	%eax, 12(%rsp)

	movl %eax, 12(%rbp)
//X8664:    	movl	%eax, 12(%rbp)

	movl %eax, 12(%r15)
//X8664:    	movl	%eax, 12(%r15)

	movl %eax, 12(%rip)
//X8664:    	movl	%eax, 12(%rip)

	movl %eax, -12(,%rsp)
//X8664:    	movl	%eax, -12(%rsp)

	movl %eax, -12(,%rbp)
//X8664:    	movl	%eax, -12(%rbp)

	movl %eax, -12(,%r15)
//X8664:    	movl	%eax, -12(%r15)

	movl %eax, 131072(%rsp, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movl	%eax, 131072(%rsp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movl %eax, 131072(%rbp, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movl	%eax, 131072(%rbp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movl %eax, 131072(%r15, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movl	%eax, 131072(%r15,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movl %eax, 131072(%rax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movl	%eax, 131072(%r15,%rax)
//X8664-NEXT: 	.bundle_unlock

	movl %eax, 131072(,%rax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %r11d
//X8664-NEXT: 	movl	%eax, (%r15,%r11)
//X8664-NEXT: 	.bundle_unlock

	movl %eax, 131072(%rax, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	movl	%eax, (%r15,%r11)
//X8664-NEXT: 	.bundle_unlock

	movw %ax, 12(%rsp)
//X8664:    	movw	%ax, 12(%rsp)

	movw %ax, 12(%rbp)
//X8664:    	movw	%ax, 12(%rbp)

	movw %ax, 12(%r15)
//X8664:    	movw	%ax, 12(%r15)

	movw %ax, 12(%rip)
//X8664:    	movw	%ax, 12(%rip)

	movw %ax, -12(,%rsp)
//X8664:    	movw	%ax, -12(%rsp)

	movw %ax, -12(,%rbp)
//X8664:    	movw	%ax, -12(%rbp)

	movw %ax, -12(,%r15)
//X8664:    	movw	%ax, -12(%r15)

	movw %ax, 131072(%rsp, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movw	%ax, 131072(%rsp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movw %ax, 131072(%rbp, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movw	%ax, 131072(%rbp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movw %ax, 131072(%r15, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movw	%ax, 131072(%r15,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movw %ax, 131072(%rax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movw	%ax, 131072(%r15,%rax)
//X8664-NEXT: 	.bundle_unlock

	movw %ax, 131072(,%rax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %r11d
//X8664-NEXT: 	movw	%ax, (%r15,%r11)
//X8664-NEXT: 	.bundle_unlock

	movw %ax, 131072(%rax, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	movw	%ax, (%r15,%r11)
//X8664-NEXT: 	.bundle_unlock

	movb %ah, 12(%rsp)
//X8664:    	movb	%ah, 12(%rsp)

	movb %ah, 12(%rbp)
//X8664:    	movb	%ah, 12(%rbp)

	movb %ah, 12(%r15)
//X8664:    	movb	%ah, 12(%r15)

	movb %ah, 12(%rip)
//X8664:    	movb	%ah, 12(%rip)

	movb %ah, -12(,%rsp)
//X8664:    	movb	%ah, -12(%rsp)

	movb %ah, -12(,%rbp)
//X8664:    	movb	%ah, -12(%rbp)

	movb %ah, -12(,%r15)
//X8664:    	movb	%ah, -12(%r15)

	movb %ah, 131072(%rsp, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movb	%ah, 131072(%rsp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movb %ah, 131072(%rbp, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movb	%ah, 131072(%rbp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movb %ah, 131072(%r15, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movb	%ah, 131072(%r15,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movb %ah, 131072(%rax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movb	%ah, 131072(%r15,%rax)
//X8664-NEXT: 	.bundle_unlock

	movb %ah, 131072(,%rax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %r11d
//X8664-NEXT: 	movb	%ah, (%r15,%r11)
//X8664-NEXT: 	.bundle_unlock

	movb %ah, 131072(%rax, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	movb	%ah, (%r15,%r11)
//X8664-NEXT: 	.bundle_unlock

	movb %al, 12(%rsp)
//X8664:    	movb	%al, 12(%rsp)

	movb %al, 12(%rbp)
//X8664:    	movb	%al, 12(%rbp)

	movb %al, 12(%r15)
//X8664:    	movb	%al, 12(%r15)

	movb %al, 12(%rip)
//X8664:    	movb	%al, 12(%rip)

	movb %al, -12(,%rsp)
//X8664:    	movb	%al, -12(%rsp)

	movb %al, -12(,%rbp)
//X8664:    	movb	%al, -12(%rbp)

	movb %al, -12(,%r15)
//X8664:    	movb	%al, -12(%r15)

	movb %al, 131072(%rsp, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movb	%al, 131072(%rsp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movb %al, 131072(%rbp, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movb	%al, 131072(%rbp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movb %al, 131072(%r15, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movb	%al, 131072(%r15,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movb %al, 131072(%rax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movb	%al, 131072(%r15,%rax)
//X8664-NEXT: 	.bundle_unlock

	movb %al, 131072(,%rax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %r11d
//X8664-NEXT: 	movb	%al, (%r15,%r11)
//X8664-NEXT: 	.bundle_unlock

	movb %al, 131072(%rax, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	movb	%al, (%r15,%r11)
//X8664-NEXT: 	.bundle_unlock


	prefetchw 12(%rsp)
//X8664:    	prefetchw	12(%rsp)

	prefetchw 12(%rbp)
//X8664:    	prefetchw	12(%rbp)

	prefetchw 12(%r15)
//X8664:    	prefetchw	12(%r15)

	prefetchw 12(%rip)
//X8664:    	prefetchw	12(%rip)

	prefetchw -12(,%rsp)
//X8664:    	prefetchw	-12(%rsp)

	prefetchw -12(,%rbp)
//X8664:    	prefetchw	-12(%rbp)

	prefetchw -12(,%r15)
//X8664:    	prefetchw	-12(%r15)

	prefetchw 131072(%rsp, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	prefetchw	131072(%rsp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	prefetchw 131072(%rbp, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	prefetchw	131072(%rbp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	prefetchw 131072(%r15, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	prefetchw	131072(%r15,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	prefetchw 131072(%rax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	prefetchw	131072(%r15,%rax)
//X8664-NEXT: 	.bundle_unlock

	prefetchw 131072(,%rax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %r11d
//X8664-NEXT: 	prefetchw	(%r15,%r11)
//X8664-NEXT: 	.bundle_unlock

	prefetchw 131072(%rax, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	prefetchw	(%r15,%r11)
//X8664-NEXT: 	.bundle_unlock
