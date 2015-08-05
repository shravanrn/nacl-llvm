// RUN: llvm-mc -filetype asm -triple i686-unknown-nacl %s | FileCheck %s --check-prefix=X8632
// RUN: llvm-mc -filetype asm -triple x86_64-unknown-nacl %s | FileCheck %s --check-prefix=X8664


.scratch %ecx


	movl $12, 12(%esp)
//X8632:    	movl	$12, 12(%esp)
//X8664:    	movl	$12, 12(%rsp)

	movl $12, 12(%ebp)
//X8632:    	movl	$12, 12(%ebp)
//X8664:    	movl	$12, 12(%rbp)

	movl $12, 12(%eip)
//X8632:    	movl	$12, 12(%eip)
//X8664:    	movl	$12, 12(%rip)

	movl $12, -12(,%esp)
//X8632:    	movl	$12, -12(,%esp)
//X8664:    	movl	$12, -12(%rsp)

	movl $12, -12(,%ebp)
//X8632:    	movl	$12, -12(,%ebp)
//X8664:    	movl	$12, -12(%rbp)

	movl $12, 131072(%esp, %edi, 8)
//X8632:    	movl	$12, 131072(%esp,%edi,8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movl	$12, 131072(%rsp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movl $12, 131072(%ebp, %edi, 8)
//X8632:    	movl	$12, 131072(%ebp,%edi,8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movl	$12, 131072(%rbp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movl $12, 131072(%eax)
//X8632:    	movl	$12, 131072(%eax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movl	$12, 131072(%r15,%rax)
//X8664-NEXT: 	.bundle_unlock

	movl $12, 131072(,%eax)
//X8632:    	movl	$12, 131072(,%eax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %ecx
//X8664-NEXT: 	movl	$12, (%r15,%rcx)
//X8664-NEXT: 	.bundle_unlock

	movl $12, 131072(%eax, %edi, 8)
//X8632:    	movl	$12, 131072(%eax,%edi,8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %ecx
//X8664-NEXT: 	movl	$12, (%r15,%rcx)
//X8664-NEXT: 	.bundle_unlock

	movl $131072, 12(%esp)
//X8632:    	movl	$131072, 12(%esp)       
//X8664:    	movl	$131072, 12(%rsp)       

	movl $131072, 12(%ebp)
//X8632:    	movl	$131072, 12(%ebp)       
//X8664:    	movl	$131072, 12(%rbp)       

	movl $131072, 12(%eip)
//X8632:    	movl	$131072, 12(%eip)       
//X8664:    	movl	$131072, 12(%rip)       

	movl $131072, -12(,%esp)
//X8632:    	movl	$131072, -12(,%esp)     
//X8664:    	movl	$131072, -12(%rsp)      

	movl $131072, -12(,%ebp)
//X8632:    	movl	$131072, -12(,%ebp)     
//X8664:    	movl	$131072, -12(%rbp)      

	movl $131072, 131072(%esp, %edi, 8)
//X8632:    	movl	$131072, 131072(%esp,%edi,8) 
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movl	$131072, 131072(%rsp,%rdi,8) 
//X8664-NEXT: 	.bundle_unlock

	movl $131072, 131072(%ebp, %edi, 8)
//X8632:    	movl	$131072, 131072(%ebp,%edi,8) 
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movl	$131072, 131072(%rbp,%rdi,8) 
//X8664-NEXT: 	.bundle_unlock

	movl $131072, 131072(%eax)
//X8632:    	movl	$131072, 131072(%eax)   
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movl	$131072, 131072(%r15,%rax) 
//X8664-NEXT: 	.bundle_unlock

	movl $131072, 131072(,%eax)
//X8632:    	movl	$131072, 131072(,%eax)  
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %ecx
//X8664-NEXT: 	movl	$131072, (%r15,%rcx)    
//X8664-NEXT: 	.bundle_unlock

	movl $131072, 131072(%eax, %edi, 8)
//X8632:    	movl	$131072, 131072(%eax,%edi,8) 
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %ecx
//X8664-NEXT: 	movl	$131072, (%r15,%rcx)    
//X8664-NEXT: 	.bundle_unlock

	movw $12, 12(%esp)
//X8632:    	movw	$12, 12(%esp)
//X8664:    	movw	$12, 12(%rsp)

	movw $12, 12(%ebp)
//X8632:    	movw	$12, 12(%ebp)
//X8664:    	movw	$12, 12(%rbp)

	movw $12, 12(%eip)
//X8632:    	movw	$12, 12(%eip)
//X8664:    	movw	$12, 12(%rip)

	movw $12, -12(,%esp)
//X8632:    	movw	$12, -12(,%esp)
//X8664:    	movw	$12, -12(%rsp)

	movw $12, -12(,%ebp)
//X8632:    	movw	$12, -12(,%ebp)
//X8664:    	movw	$12, -12(%rbp)

	movw $12, 131072(%esp, %edi, 8)
//X8632:    	movw	$12, 131072(%esp,%edi,8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movw	$12, 131072(%rsp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movw $12, 131072(%ebp, %edi, 8)
//X8632:    	movw	$12, 131072(%ebp,%edi,8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movw	$12, 131072(%rbp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movw $12, 131072(%eax)
//X8632:    	movw	$12, 131072(%eax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movw	$12, 131072(%r15,%rax)
//X8664-NEXT: 	.bundle_unlock

	movw $12, 131072(,%eax)
//X8632:    	movw	$12, 131072(,%eax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %ecx
//X8664-NEXT: 	movw	$12, (%r15,%rcx)
//X8664-NEXT: 	.bundle_unlock

	movw $12, 131072(%eax, %edi, 8)
//X8632:    	movw	$12, 131072(%eax,%edi,8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %ecx
//X8664-NEXT: 	movw	$12, (%r15,%rcx)
//X8664-NEXT: 	.bundle_unlock

	movw $131072, 12(%esp)
//X8632:    	movw	$131072, 12(%esp)       
//X8664:    	movw	$131072, 12(%rsp)       

	movw $131072, 12(%ebp)
//X8632:    	movw	$131072, 12(%ebp)       
//X8664:    	movw	$131072, 12(%rbp)       

	movw $131072, 12(%eip)
//X8632:    	movw	$131072, 12(%eip)       
//X8664:    	movw	$131072, 12(%rip)       

	movw $131072, -12(,%esp)
//X8632:    	movw	$131072, -12(,%esp)     
//X8664:    	movw	$131072, -12(%rsp)      

	movw $131072, -12(,%ebp)
//X8632:    	movw	$131072, -12(,%ebp)     
//X8664:    	movw	$131072, -12(%rbp)      

	movw $131072, 131072(%esp, %edi, 8)
//X8632:    	movw	$131072, 131072(%esp,%edi,8) 
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movw	$131072, 131072(%rsp,%rdi,8) 
//X8664-NEXT: 	.bundle_unlock

	movw $131072, 131072(%ebp, %edi, 8)
//X8632:    	movw	$131072, 131072(%ebp,%edi,8) 
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movw	$131072, 131072(%rbp,%rdi,8) 
//X8664-NEXT: 	.bundle_unlock

	movw $131072, 131072(%eax)
//X8632:    	movw	$131072, 131072(%eax)   
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movw	$131072, 131072(%r15,%rax) 
//X8664-NEXT: 	.bundle_unlock

	movw $131072, 131072(,%eax)
//X8632:    	movw	$131072, 131072(,%eax)  
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %ecx
//X8664-NEXT: 	movw	$131072, (%r15,%rcx)    
//X8664-NEXT: 	.bundle_unlock

	movw $131072, 131072(%eax, %edi, 8)
//X8632:    	movw	$131072, 131072(%eax,%edi,8) 
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %ecx
//X8664-NEXT: 	movw	$131072, (%r15,%rcx)    
//X8664-NEXT: 	.bundle_unlock

	movb $12, 12(%esp)
//X8632:    	movb	$12, 12(%esp)
//X8664:    	movb	$12, 12(%rsp)

	movb $12, 12(%ebp)
//X8632:    	movb	$12, 12(%ebp)
//X8664:    	movb	$12, 12(%rbp)

	movb $12, 12(%eip)
//X8632:    	movb	$12, 12(%eip)
//X8664:    	movb	$12, 12(%rip)

	movb $12, -12(,%esp)
//X8632:    	movb	$12, -12(,%esp)
//X8664:    	movb	$12, -12(%rsp)

	movb $12, -12(,%ebp)
//X8632:    	movb	$12, -12(,%ebp)
//X8664:    	movb	$12, -12(%rbp)

	movb $12, 131072(%esp, %edi, 8)
//X8632:    	movb	$12, 131072(%esp,%edi,8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movb	$12, 131072(%rsp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movb $12, 131072(%ebp, %edi, 8)
//X8632:    	movb	$12, 131072(%ebp,%edi,8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movb	$12, 131072(%rbp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movb $12, 131072(%eax)
//X8632:    	movb	$12, 131072(%eax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movb	$12, 131072(%r15,%rax)
//X8664-NEXT: 	.bundle_unlock

	movb $12, 131072(,%eax)
//X8632:    	movb	$12, 131072(,%eax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %ecx
//X8664-NEXT: 	movb	$12, (%r15,%rcx)
//X8664-NEXT: 	.bundle_unlock

	movb $12, 131072(%eax, %edi, 8)
//X8632:    	movb	$12, 131072(%eax,%edi,8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %ecx
//X8664-NEXT: 	movb	$12, (%r15,%rcx)
//X8664-NEXT: 	.bundle_unlock

	movb $131072, 12(%esp)
//X8632:    	movb	$131072, 12(%esp)       
//X8664:    	movb	$131072, 12(%rsp)       

	movb $131072, 12(%ebp)
//X8632:    	movb	$131072, 12(%ebp)       
//X8664:    	movb	$131072, 12(%rbp)       

	movb $131072, 12(%eip)
//X8632:    	movb	$131072, 12(%eip)       
//X8664:    	movb	$131072, 12(%rip)       

	movb $131072, -12(,%esp)
//X8632:    	movb	$131072, -12(,%esp)     
//X8664:    	movb	$131072, -12(%rsp)      

	movb $131072, -12(,%ebp)
//X8632:    	movb	$131072, -12(,%ebp)     
//X8664:    	movb	$131072, -12(%rbp)      

	movb $131072, 131072(%esp, %edi, 8)
//X8632:    	movb	$131072, 131072(%esp,%edi,8) 
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movb	$131072, 131072(%rsp,%rdi,8) 
//X8664-NEXT: 	.bundle_unlock

	movb $131072, 131072(%ebp, %edi, 8)
//X8632:    	movb	$131072, 131072(%ebp,%edi,8) 
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movb	$131072, 131072(%rbp,%rdi,8) 
//X8664-NEXT: 	.bundle_unlock

	movb $131072, 131072(%eax)
//X8632:    	movb	$131072, 131072(%eax)   
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movb	$131072, 131072(%r15,%rax) 
//X8664-NEXT: 	.bundle_unlock

	movb $131072, 131072(,%eax)
//X8632:    	movb	$131072, 131072(,%eax)  
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %ecx
//X8664-NEXT: 	movb	$131072, (%r15,%rcx)    
//X8664-NEXT: 	.bundle_unlock

	movb $131072, 131072(%eax, %edi, 8)
//X8632:    	movb	$131072, 131072(%eax,%edi,8) 
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %ecx
//X8664-NEXT: 	movb	$131072, (%r15,%rcx)    
//X8664-NEXT: 	.bundle_unlock
	

	movl %eax, 12(%esp)
//X8632:    	movl	%eax, 12(%esp)
//X8664:    	movl	%eax, 12(%rsp)

	movl %eax, 12(%ebp)
//X8632:    	movl	%eax, 12(%ebp)
//X8664:    	movl	%eax, 12(%rbp)

	movl %eax, 12(%eip)
//X8632:    	movl	%eax, 12(%eip)
//X8664:    	movl	%eax, 12(%rip)

	movl %eax, -12(,%esp)
//X8632:    	movl	%eax, -12(,%esp)
//X8664:    	movl	%eax, -12(%rsp)

	movl %eax, -12(,%ebp)
//X8632:    	movl	%eax, -12(,%ebp)
//X8664:    	movl	%eax, -12(%rbp)

	movl %eax, 131072(%esp, %edi, 8)
//X8632:    	movl	%eax, 131072(%esp,%edi,8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movl	%eax, 131072(%rsp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movl %eax, 131072(%ebp, %edi, 8)
//X8632:    	movl	%eax, 131072(%ebp,%edi,8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movl	%eax, 131072(%rbp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movl %eax, 131072(%eax)
//X8632:    	movl	%eax, 131072(%eax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movl	%eax, 131072(%r15,%rax)
//X8664-NEXT: 	.bundle_unlock

	movl %eax, 131072(,%eax)
//X8632:    	movl	%eax, 131072(,%eax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %ecx
//X8664-NEXT: 	movl	%eax, (%r15,%rcx)
//X8664-NEXT: 	.bundle_unlock

	movl %eax, 131072(%eax, %edi, 8)
//X8632:    	movl	%eax, 131072(%eax,%edi,8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %ecx
//X8664-NEXT: 	movl	%eax, (%r15,%rcx)
//X8664-NEXT: 	.bundle_unlock

	movw %ax, 12(%esp)
//X8632:    	movw	%ax, 12(%esp)
//X8664:    	movw	%ax, 12(%rsp)

	movw %ax, 12(%ebp)
//X8632:    	movw	%ax, 12(%ebp)
//X8664:    	movw	%ax, 12(%rbp)

	movw %ax, 12(%eip)
//X8632:    	movw	%ax, 12(%eip)
//X8664:    	movw	%ax, 12(%rip)

	movw %ax, -12(,%esp)
//X8632:    	movw	%ax, -12(,%esp)
//X8664:    	movw	%ax, -12(%rsp)

	movw %ax, -12(,%ebp)
//X8632:    	movw	%ax, -12(,%ebp)
//X8664:    	movw	%ax, -12(%rbp)

	movw %ax, 131072(%esp, %edi, 8)
//X8632:    	movw	%ax, 131072(%esp,%edi,8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movw	%ax, 131072(%rsp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movw %ax, 131072(%ebp, %edi, 8)
//X8632:    	movw	%ax, 131072(%ebp,%edi,8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movw	%ax, 131072(%rbp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movw %ax, 131072(%eax)
//X8632:    	movw	%ax, 131072(%eax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movw	%ax, 131072(%r15,%rax)
//X8664-NEXT: 	.bundle_unlock

	movw %ax, 131072(,%eax)
//X8632:    	movw	%ax, 131072(,%eax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %ecx
//X8664-NEXT: 	movw	%ax, (%r15,%rcx)
//X8664-NEXT: 	.bundle_unlock

	movw %ax, 131072(%eax, %edi, 8)
//X8632:    	movw	%ax, 131072(%eax,%edi,8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %ecx
//X8664-NEXT: 	movw	%ax, (%r15,%rcx)
//X8664-NEXT: 	.bundle_unlock

	movb %ah, 12(%esp)
//X8632:    	movb	%ah, 12(%esp)
//X8664:    	movb	%ah, 12(%rsp)

	movb %ah, 12(%ebp)
//X8632:    	movb	%ah, 12(%ebp)
//X8664:    	movb	%ah, 12(%rbp)

	movb %ah, 12(%eip)
//X8632:    	movb	%ah, 12(%eip)
//X8664:    	movb	%ah, 12(%rip)

	movb %ah, -12(,%esp)
//X8632:    	movb	%ah, -12(,%esp)
//X8664:    	movb	%ah, -12(%rsp)

	movb %ah, -12(,%ebp)
//X8632:    	movb	%ah, -12(,%ebp)
//X8664:    	movb	%ah, -12(%rbp)

	movb %ah, 131072(%esp, %edi, 8)
//X8632:    	movb	%ah, 131072(%esp,%edi,8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movb	%ah, 131072(%rsp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movb %ah, 131072(%ebp, %edi, 8)
//X8632:    	movb	%ah, 131072(%ebp,%edi,8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movb	%ah, 131072(%rbp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movb %ah, 131072(%eax)
//X8632:    	movb	%ah, 131072(%eax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movb	%ah, 131072(%r15,%rax)
//X8664-NEXT: 	.bundle_unlock

	movb %ah, 131072(,%eax)
//X8632:    	movb	%ah, 131072(,%eax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %ecx
//X8664-NEXT: 	movb	%ah, (%r15,%rcx)
//X8664-NEXT: 	.bundle_unlock

	movb %ah, 131072(%eax, %edi, 8)
//X8632:    	movb	%ah, 131072(%eax,%edi,8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %ecx
//X8664-NEXT: 	movb	%ah, (%r15,%rcx)
//X8664-NEXT: 	.bundle_unlock

	movb %al, 12(%esp)
//X8632:    	movb	%al, 12(%esp)
//X8664:    	movb	%al, 12(%rsp)

	movb %al, 12(%ebp)
//X8632:    	movb	%al, 12(%ebp)
//X8664:    	movb	%al, 12(%rbp)

	movb %al, 12(%eip)
//X8632:    	movb	%al, 12(%eip)
//X8664:    	movb	%al, 12(%rip)

	movb %al, -12(,%esp)
//X8632:    	movb	%al, -12(,%esp)
//X8664:    	movb	%al, -12(%rsp)

	movb %al, -12(,%ebp)
//X8632:    	movb	%al, -12(,%ebp)
//X8664:    	movb	%al, -12(%rbp)

	movb %al, 131072(%esp, %edi, 8)
//X8632:    	movb	%al, 131072(%esp,%edi,8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movb	%al, 131072(%rsp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movb %al, 131072(%ebp, %edi, 8)
//X8632:    	movb	%al, 131072(%ebp,%edi,8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	movb	%al, 131072(%rbp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	movb %al, 131072(%eax)
//X8632:    	movb	%al, 131072(%eax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	movb	%al, 131072(%r15,%rax)
//X8664-NEXT: 	.bundle_unlock

	movb %al, 131072(,%eax)
//X8632:    	movb	%al, 131072(,%eax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %ecx
//X8664-NEXT: 	movb	%al, (%r15,%rcx)
//X8664-NEXT: 	.bundle_unlock

	movb %al, 131072(%eax, %edi, 8)
//X8632:    	movb	%al, 131072(%eax,%edi,8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %ecx
//X8664-NEXT: 	movb	%al, (%r15,%rcx)
//X8664-NEXT: 	.bundle_unlock


	prefetchw 12(%esp)
//X8632:    	prefetchw	12(%esp)
//X8664:    	prefetchw	12(%rsp)

	prefetchw 12(%ebp)
//X8632:    	prefetchw	12(%ebp)
//X8664:    	prefetchw	12(%rbp)

	prefetchw 12(%eip)
//X8632:    	prefetchw	12(%eip)
//X8664:    	prefetchw	12(%rip)

	prefetchw -12(,%esp)
//X8632:    	prefetchw	-12(,%esp)
//X8664:    	prefetchw	-12(%rsp)

	prefetchw -12(,%ebp)
//X8632:    	prefetchw	-12(,%ebp)
//X8664:    	prefetchw	-12(%rbp)

	prefetchw 131072(%esp, %edi, 8)
//X8632:    	prefetchw	131072(%esp,%edi,8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	prefetchw	131072(%rsp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	prefetchw 131072(%ebp, %edi, 8)
//X8632:    	prefetchw	131072(%ebp,%edi,8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	prefetchw	131072(%rbp,%rdi,8)
//X8664-NEXT: 	.bundle_unlock

	prefetchw 131072(%eax)
//X8632:    	prefetchw	131072(%eax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%eax, %eax
//X8664-NEXT: 	prefetchw	131072(%r15,%rax)
//X8664-NEXT: 	.bundle_unlock

	prefetchw 131072(,%eax)
//X8632:    	prefetchw	131072(,%eax)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax), %ecx
//X8664-NEXT: 	prefetchw	(%r15,%rcx)
//X8664-NEXT: 	.bundle_unlock

	prefetchw 131072(%eax, %edi, 8)
//X8632:    	prefetchw	131072(%eax,%edi,8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %ecx
//X8664-NEXT: 	prefetchw	(%r15,%rcx)
//X8664-NEXT: 	.bundle_unlock

	
	
