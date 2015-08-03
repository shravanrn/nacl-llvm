// RUN: llvm-mc -filetype asm -triple x86_64-unknown-nacl %s | FileCheck %s


.scratch %r11


	movq $12, 12(%rsp)
//CHECK:    	movq	$12, 12(%rsp)

	movq $12, 12(%rbp)
//CHECK:    	movq	$12, 12(%rbp)

	movq $12, 12(%r15)
//CHECK:    	movq	$12, 12(%r15)

	movq $12, 12(%rip)
//CHECK:    	movq	$12, 12(%rip)

	movq $12, -12(,%rsp)
//CHECK:    	movq	$12, -12(%rsp)

	movq $12, -12(,%rbp)
//CHECK:    	movq	$12, -12(%rbp)

	movq $12, -12(,%r15)
//CHECK:    	movq	$12, -12(%r15)

	movq $12, -12(,%rip)
//CHECK:    	movq	$12, -12(%rip)

	movq $12, 131072(%rsp, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movq	$12, 131072(%rsp,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movq $12, 131072(%rbp, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movq	$12, 131072(%rbp,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movq $12, 131072(%r15, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movq	$12, 131072(%r15,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movq $12, 131072(%rip, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movq	$12, 131072(%rip,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movq $12, 131072(%rax)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%eax, %eax
//CHECK-NEXT: 	movq	$12, 131072(%r15,%rax)
//CHECK-NEXT: 	.bundle_unlock

	movq $12, 131072(,%rax)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(,%rax), %r11d
//CHECK-NEXT: 	movq	$12, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock

	movq $12, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	movq	$12, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock

	movq $131072, 12(%rsp)
//CHECK:    	movq	$131072, 12(%rsp)       

	movq $131072, 12(%rbp)
//CHECK:    	movq	$131072, 12(%rbp)       

	movq $131072, 12(%r15)
//CHECK:    	movq	$131072, 12(%r15)       

	movq $131072, 12(%rip)
//CHECK:    	movq	$131072, 12(%rip)       

	movq $131072, -12(,%rsp)
//CHECK:    	movq	$131072, -12(%rsp)      

	movq $131072, -12(,%rbp)
//CHECK:    	movq	$131072, -12(%rbp)      

	movq $131072, -12(,%r15)
//CHECK:    	movq	$131072, -12(%r15)      

	movq $131072, -12(,%rip)
//CHECK:    	movq	$131072, -12(%rip)      

	movq $131072, 131072(%rsp, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movq	$131072, 131072(%rsp,%rdi,8) 
//CHECK-NEXT: 	.bundle_unlock

	movq $131072, 131072(%rbp, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movq	$131072, 131072(%rbp,%rdi,8) 
//CHECK-NEXT: 	.bundle_unlock

	movq $131072, 131072(%r15, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movq	$131072, 131072(%r15,%rdi,8) 
//CHECK-NEXT: 	.bundle_unlock

	movq $131072, 131072(%rip, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movq	$131072, 131072(%rip,%rdi,8) 
//CHECK-NEXT: 	.bundle_unlock

	movq $131072, 131072(%rax)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%eax, %eax
//CHECK-NEXT: 	movq	$131072, 131072(%r15,%rax) 
//CHECK-NEXT: 	.bundle_unlock

	movq $131072, 131072(,%rax)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(,%rax), %r11d
//CHECK-NEXT: 	movq	$131072, (%r15,%r11)    
//CHECK-NEXT: 	.bundle_unlock

	movq $131072, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	movq	$131072, (%r15,%r11)    
//CHECK-NEXT: 	.bundle_unlock

	movl $12, 12(%rsp)
//CHECK:    	movl	$12, 12(%rsp)

	movl $12, 12(%rbp)
//CHECK:    	movl	$12, 12(%rbp)

	movl $12, 12(%r15)
//CHECK:    	movl	$12, 12(%r15)

	movl $12, 12(%rip)
//CHECK:    	movl	$12, 12(%rip)

	movl $12, -12(,%rsp)
//CHECK:    	movl	$12, -12(%rsp)

	movl $12, -12(,%rbp)
//CHECK:    	movl	$12, -12(%rbp)

	movl $12, -12(,%r15)
//CHECK:    	movl	$12, -12(%r15)

	movl $12, -12(,%rip)
//CHECK:    	movl	$12, -12(%rip)

	movl $12, 131072(%rsp, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movl	$12, 131072(%rsp,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movl $12, 131072(%rbp, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movl	$12, 131072(%rbp,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movl $12, 131072(%r15, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movl	$12, 131072(%r15,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movl $12, 131072(%rip, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movl	$12, 131072(%rip,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movl $12, 131072(%rax)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%eax, %eax
//CHECK-NEXT: 	movl	$12, 131072(%r15,%rax)
//CHECK-NEXT: 	.bundle_unlock

	movl $12, 131072(,%rax)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(,%rax), %r11d
//CHECK-NEXT: 	movl	$12, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock

	movl $12, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	movl	$12, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock

	movl $131072, 12(%rsp)
//CHECK:    	movl	$131072, 12(%rsp)       

	movl $131072, 12(%rbp)
//CHECK:    	movl	$131072, 12(%rbp)       

	movl $131072, 12(%r15)
//CHECK:    	movl	$131072, 12(%r15)       

	movl $131072, 12(%rip)
//CHECK:    	movl	$131072, 12(%rip)       

	movl $131072, -12(,%rsp)
//CHECK:    	movl	$131072, -12(%rsp)      

	movl $131072, -12(,%rbp)
//CHECK:    	movl	$131072, -12(%rbp)      

	movl $131072, -12(,%r15)
//CHECK:    	movl	$131072, -12(%r15)      

	movl $131072, -12(,%rip)
//CHECK:    	movl	$131072, -12(%rip)      

	movl $131072, 131072(%rsp, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movl	$131072, 131072(%rsp,%rdi,8) 
//CHECK-NEXT: 	.bundle_unlock

	movl $131072, 131072(%rbp, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movl	$131072, 131072(%rbp,%rdi,8) 
//CHECK-NEXT: 	.bundle_unlock

	movl $131072, 131072(%r15, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movl	$131072, 131072(%r15,%rdi,8) 
//CHECK-NEXT: 	.bundle_unlock

	movl $131072, 131072(%rip, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movl	$131072, 131072(%rip,%rdi,8) 
//CHECK-NEXT: 	.bundle_unlock

	movl $131072, 131072(%rax)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%eax, %eax
//CHECK-NEXT: 	movl	$131072, 131072(%r15,%rax) 
//CHECK-NEXT: 	.bundle_unlock

	movl $131072, 131072(,%rax)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(,%rax), %r11d
//CHECK-NEXT: 	movl	$131072, (%r15,%r11)    
//CHECK-NEXT: 	.bundle_unlock

	movl $131072, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	movl	$131072, (%r15,%r11)    
//CHECK-NEXT: 	.bundle_unlock

	movw $12, 12(%rsp)
//CHECK:    	movw	$12, 12(%rsp)

	movw $12, 12(%rbp)
//CHECK:    	movw	$12, 12(%rbp)

	movw $12, 12(%r15)
//CHECK:    	movw	$12, 12(%r15)

	movw $12, 12(%rip)
//CHECK:    	movw	$12, 12(%rip)

	movw $12, -12(,%rsp)
//CHECK:    	movw	$12, -12(%rsp)

	movw $12, -12(,%rbp)
//CHECK:    	movw	$12, -12(%rbp)

	movw $12, -12(,%r15)
//CHECK:    	movw	$12, -12(%r15)

	movw $12, -12(,%rip)
//CHECK:    	movw	$12, -12(%rip)

	movw $12, 131072(%rsp, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movw	$12, 131072(%rsp,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movw $12, 131072(%rbp, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movw	$12, 131072(%rbp,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movw $12, 131072(%r15, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movw	$12, 131072(%r15,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movw $12, 131072(%rip, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movw	$12, 131072(%rip,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movw $12, 131072(%rax)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%eax, %eax
//CHECK-NEXT: 	movw	$12, 131072(%r15,%rax)
//CHECK-NEXT: 	.bundle_unlock

	movw $12, 131072(,%rax)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(,%rax), %r11d
//CHECK-NEXT: 	movw	$12, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock

	movw $12, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	movw	$12, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock

	movw $131072, 12(%rsp)
//CHECK:    	movw	$131072, 12(%rsp)       

	movw $131072, 12(%rbp)
//CHECK:    	movw	$131072, 12(%rbp)       

	movw $131072, 12(%r15)
//CHECK:    	movw	$131072, 12(%r15)       

	movw $131072, 12(%rip)
//CHECK:    	movw	$131072, 12(%rip)       

	movw $131072, -12(,%rsp)
//CHECK:    	movw	$131072, -12(%rsp)      

	movw $131072, -12(,%rbp)
//CHECK:    	movw	$131072, -12(%rbp)      

	movw $131072, -12(,%r15)
//CHECK:    	movw	$131072, -12(%r15)      

	movw $131072, -12(,%rip)
//CHECK:    	movw	$131072, -12(%rip)      

	movw $131072, 131072(%rsp, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movw	$131072, 131072(%rsp,%rdi,8) 
//CHECK-NEXT: 	.bundle_unlock

	movw $131072, 131072(%rbp, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movw	$131072, 131072(%rbp,%rdi,8) 
//CHECK-NEXT: 	.bundle_unlock

	movw $131072, 131072(%r15, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movw	$131072, 131072(%r15,%rdi,8) 
//CHECK-NEXT: 	.bundle_unlock

	movw $131072, 131072(%rip, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movw	$131072, 131072(%rip,%rdi,8) 
//CHECK-NEXT: 	.bundle_unlock

	movw $131072, 131072(%rax)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%eax, %eax
//CHECK-NEXT: 	movw	$131072, 131072(%r15,%rax) 
//CHECK-NEXT: 	.bundle_unlock

	movw $131072, 131072(,%rax)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(,%rax), %r11d
//CHECK-NEXT: 	movw	$131072, (%r15,%r11)    
//CHECK-NEXT: 	.bundle_unlock

	movw $131072, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	movw	$131072, (%r15,%r11)    
//CHECK-NEXT: 	.bundle_unlock

	movb $12, 12(%rsp)
//CHECK:    	movb	$12, 12(%rsp)

	movb $12, 12(%rbp)
//CHECK:    	movb	$12, 12(%rbp)

	movb $12, 12(%r15)
//CHECK:    	movb	$12, 12(%r15)

	movb $12, 12(%rip)
//CHECK:    	movb	$12, 12(%rip)

	movb $12, -12(,%rsp)
//CHECK:    	movb	$12, -12(%rsp)

	movb $12, -12(,%rbp)
//CHECK:    	movb	$12, -12(%rbp)

	movb $12, -12(,%r15)
//CHECK:    	movb	$12, -12(%r15)

	movb $12, -12(,%rip)
//CHECK:    	movb	$12, -12(%rip)

	movb $12, 131072(%rsp, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movb	$12, 131072(%rsp,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movb $12, 131072(%rbp, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movb	$12, 131072(%rbp,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movb $12, 131072(%r15, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movb	$12, 131072(%r15,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movb $12, 131072(%rip, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movb	$12, 131072(%rip,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movb $12, 131072(%rax)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%eax, %eax
//CHECK-NEXT: 	movb	$12, 131072(%r15,%rax)
//CHECK-NEXT: 	.bundle_unlock

	movb $12, 131072(,%rax)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(,%rax), %r11d
//CHECK-NEXT: 	movb	$12, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock

	movb $12, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	movb	$12, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock

	movb $131072, 12(%rsp)
//CHECK:    	movb	$131072, 12(%rsp)       

	movb $131072, 12(%rbp)
//CHECK:    	movb	$131072, 12(%rbp)       

	movb $131072, 12(%r15)
//CHECK:    	movb	$131072, 12(%r15)       

	movb $131072, 12(%rip)
//CHECK:    	movb	$131072, 12(%rip)       

	movb $131072, -12(,%rsp)
//CHECK:    	movb	$131072, -12(%rsp)      

	movb $131072, -12(,%rbp)
//CHECK:    	movb	$131072, -12(%rbp)      

	movb $131072, -12(,%r15)
//CHECK:    	movb	$131072, -12(%r15)      

	movb $131072, -12(,%rip)
//CHECK:    	movb	$131072, -12(%rip)      

	movb $131072, 131072(%rsp, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movb	$131072, 131072(%rsp,%rdi,8) 
//CHECK-NEXT: 	.bundle_unlock

	movb $131072, 131072(%rbp, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movb	$131072, 131072(%rbp,%rdi,8) 
//CHECK-NEXT: 	.bundle_unlock

	movb $131072, 131072(%r15, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movb	$131072, 131072(%r15,%rdi,8) 
//CHECK-NEXT: 	.bundle_unlock

	movb $131072, 131072(%rip, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movb	$131072, 131072(%rip,%rdi,8) 
//CHECK-NEXT: 	.bundle_unlock

	movb $131072, 131072(%rax)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%eax, %eax
//CHECK-NEXT: 	movb	$131072, 131072(%r15,%rax) 
//CHECK-NEXT: 	.bundle_unlock

	movb $131072, 131072(,%rax)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(,%rax), %r11d
//CHECK-NEXT: 	movb	$131072, (%r15,%r11)    
//CHECK-NEXT: 	.bundle_unlock

	movb $131072, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	movb	$131072, (%r15,%r11)    
//CHECK-NEXT: 	.bundle_unlock
	

	movq %rax, 12(%rsp)
//CHECK:    	movq	%rax, 12(%rsp)

	movq %rax, 12(%rbp)
//CHECK:    	movq	%rax, 12(%rbp)

	movq %rax, 12(%r15)
//CHECK:    	movq	%rax, 12(%r15)

	movq %rax, 12(%rip)
//CHECK:    	movq	%rax, 12(%rip)

	movq %rax, -12(,%rsp)
//CHECK:    	movq	%rax, -12(%rsp)

	movq %rax, -12(,%rbp)
//CHECK:    	movq	%rax, -12(%rbp)

	movq %rax, -12(,%r15)
//CHECK:    	movq	%rax, -12(%r15)

	movq %rax, -12(,%rip)
//CHECK:    	movq	%rax, -12(%rip)

	movq %rax, 131072(%rsp, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movq	%rax, 131072(%rsp,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movq %rax, 131072(%rbp, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movq	%rax, 131072(%rbp,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movq %rax, 131072(%r15, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movq	%rax, 131072(%r15,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movq %rax, 131072(%rip, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movq	%rax, 131072(%rip,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movq %rax, 131072(%rax)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%eax, %eax
//CHECK-NEXT: 	movq	%rax, 131072(%r15,%rax)
//CHECK-NEXT: 	.bundle_unlock

	movq %rax, 131072(,%rax)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(,%rax), %r11d
//CHECK-NEXT: 	movq	%rax, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock

	movq %rax, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	movq	%rax, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock

	movl %eax, 12(%rsp)
//CHECK:    	movl	%eax, 12(%rsp)

	movl %eax, 12(%rbp)
//CHECK:    	movl	%eax, 12(%rbp)

	movl %eax, 12(%r15)
//CHECK:    	movl	%eax, 12(%r15)

	movl %eax, 12(%rip)
//CHECK:    	movl	%eax, 12(%rip)

	movl %eax, -12(,%rsp)
//CHECK:    	movl	%eax, -12(%rsp)

	movl %eax, -12(,%rbp)
//CHECK:    	movl	%eax, -12(%rbp)

	movl %eax, -12(,%r15)
//CHECK:    	movl	%eax, -12(%r15)

	movl %eax, -12(,%rip)
//CHECK:    	movl	%eax, -12(%rip)

	movl %eax, 131072(%rsp, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movl	%eax, 131072(%rsp,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movl %eax, 131072(%rbp, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movl	%eax, 131072(%rbp,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movl %eax, 131072(%r15, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movl	%eax, 131072(%r15,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movl %eax, 131072(%rip, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movl	%eax, 131072(%rip,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movl %eax, 131072(%rax)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%eax, %eax
//CHECK-NEXT: 	movl	%eax, 131072(%r15,%rax)
//CHECK-NEXT: 	.bundle_unlock

	movl %eax, 131072(,%rax)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(,%rax), %r11d
//CHECK-NEXT: 	movl	%eax, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock

	movl %eax, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	movl	%eax, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock

	movw %ax, 12(%rsp)
//CHECK:    	movw	%ax, 12(%rsp)

	movw %ax, 12(%rbp)
//CHECK:    	movw	%ax, 12(%rbp)

	movw %ax, 12(%r15)
//CHECK:    	movw	%ax, 12(%r15)

	movw %ax, 12(%rip)
//CHECK:    	movw	%ax, 12(%rip)

	movw %ax, -12(,%rsp)
//CHECK:    	movw	%ax, -12(%rsp)

	movw %ax, -12(,%rbp)
//CHECK:    	movw	%ax, -12(%rbp)

	movw %ax, -12(,%r15)
//CHECK:    	movw	%ax, -12(%r15)

	movw %ax, -12(,%rip)
//CHECK:    	movw	%ax, -12(%rip)

	movw %ax, 131072(%rsp, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movw	%ax, 131072(%rsp,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movw %ax, 131072(%rbp, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movw	%ax, 131072(%rbp,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movw %ax, 131072(%r15, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movw	%ax, 131072(%r15,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movw %ax, 131072(%rip, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movw	%ax, 131072(%rip,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movw %ax, 131072(%rax)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%eax, %eax
//CHECK-NEXT: 	movw	%ax, 131072(%r15,%rax)
//CHECK-NEXT: 	.bundle_unlock

	movw %ax, 131072(,%rax)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(,%rax), %r11d
//CHECK-NEXT: 	movw	%ax, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock

	movw %ax, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	movw	%ax, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock

	movb %ah, 12(%rsp)
//CHECK:    	movb	%ah, 12(%rsp)

	movb %ah, 12(%rbp)
//CHECK:    	movb	%ah, 12(%rbp)

	movb %ah, 12(%r15)
//CHECK:    	movb	%ah, 12(%r15)

	movb %ah, 12(%rip)
//CHECK:    	movb	%ah, 12(%rip)

	movb %ah, -12(,%rsp)
//CHECK:    	movb	%ah, -12(%rsp)

	movb %ah, -12(,%rbp)
//CHECK:    	movb	%ah, -12(%rbp)

	movb %ah, -12(,%r15)
//CHECK:    	movb	%ah, -12(%r15)

	movb %ah, -12(,%rip)
//CHECK:    	movb	%ah, -12(%rip)

	movb %ah, 131072(%rsp, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movb	%ah, 131072(%rsp,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movb %ah, 131072(%rbp, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movb	%ah, 131072(%rbp,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movb %ah, 131072(%r15, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movb	%ah, 131072(%r15,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movb %ah, 131072(%rip, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movb	%ah, 131072(%rip,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movb %ah, 131072(%rax)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%eax, %eax
//CHECK-NEXT: 	movb	%ah, 131072(%r15,%rax)
//CHECK-NEXT: 	.bundle_unlock

	movb %ah, 131072(,%rax)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(,%rax), %r11d
//CHECK-NEXT: 	movb	%ah, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock

	movb %ah, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	movb	%ah, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock

	movb %al, 12(%rsp)
//CHECK:    	movb	%al, 12(%rsp)

	movb %al, 12(%rbp)
//CHECK:    	movb	%al, 12(%rbp)

	movb %al, 12(%r15)
//CHECK:    	movb	%al, 12(%r15)

	movb %al, 12(%rip)
//CHECK:    	movb	%al, 12(%rip)

	movb %al, -12(,%rsp)
//CHECK:    	movb	%al, -12(%rsp)

	movb %al, -12(,%rbp)
//CHECK:    	movb	%al, -12(%rbp)

	movb %al, -12(,%r15)
//CHECK:    	movb	%al, -12(%r15)

	movb %al, -12(,%rip)
//CHECK:    	movb	%al, -12(%rip)

	movb %al, 131072(%rsp, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movb	%al, 131072(%rsp,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movb %al, 131072(%rbp, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movb	%al, 131072(%rbp,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movb %al, 131072(%r15, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movb	%al, 131072(%r15,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movb %al, 131072(%rip, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	movb	%al, 131072(%rip,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	movb %al, 131072(%rax)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%eax, %eax
//CHECK-NEXT: 	movb	%al, 131072(%r15,%rax)
//CHECK-NEXT: 	.bundle_unlock

	movb %al, 131072(,%rax)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(,%rax), %r11d
//CHECK-NEXT: 	movb	%al, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock

	movb %al, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	movb	%al, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock


	prefetchw 12(%rsp)
//CHECK:    	prefetchw	12(%rsp)

	prefetchw 12(%rbp)
//CHECK:    	prefetchw	12(%rbp)

	prefetchw 12(%r15)
//CHECK:    	prefetchw	12(%r15)

	prefetchw 12(%rip)
//CHECK:    	prefetchw	12(%rip)

	prefetchw -12(,%rsp)
//CHECK:    	prefetchw	-12(%rsp)

	prefetchw -12(,%rbp)
//CHECK:    	prefetchw	-12(%rbp)

	prefetchw -12(,%r15)
//CHECK:    	prefetchw	-12(%r15)

	prefetchw -12(,%rip)
//CHECK:    	prefetchw	-12(%rip)

	prefetchw 131072(%rsp, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	prefetchw	131072(%rsp,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	prefetchw 131072(%rbp, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	prefetchw	131072(%rbp,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	prefetchw 131072(%r15, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	prefetchw	131072(%r15,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	prefetchw 131072(%rip, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%edi, %edi
//CHECK-NEXT: 	prefetchw	131072(%rip,%rdi,8)
//CHECK-NEXT: 	.bundle_unlock

	prefetchw 131072(%rax)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	movl	%eax, %eax
//CHECK-NEXT: 	prefetchw	131072(%r15,%rax)
//CHECK-NEXT: 	.bundle_unlock

	prefetchw 131072(,%rax)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(,%rax), %r11d
//CHECK-NEXT: 	prefetchw	(%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock

	prefetchw 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	prefetchw	(%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock

	
	
