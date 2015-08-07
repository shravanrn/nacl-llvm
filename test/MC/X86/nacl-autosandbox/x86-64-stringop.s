// RUN: llvm-mc -nacl-enable-auto-sandboxing -filetype asm -triple x86_64-unknown-nacl %s | FileCheck %s --check-prefix=X8664

	cmpsq (%rdi), (%rsi)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	leaq	(%r15,%rdi), %rdi
//X8664-NEXT: 	movl	%esi, %esi
//X8664-NEXT: 	leaq	(%r15,%rsi), %rsi
//X8664-NEXT: 	cmpsq	%es:(%rdi), (%rsi)
//X8664-NEXT: 	.bundle_unlock

	movsq (%rsi), (%rdi)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	leaq	(%r15,%rdi), %rdi
//X8664-NEXT: 	movl	%esi, %esi
//X8664-NEXT: 	leaq	(%r15,%rsi), %rsi
//X8664-NEXT: 	movsq	(%rsi), %es:(%rdi)
//X8664-NEXT: 	.bundle_unlock

	stosq %rax, (%rdi)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	leaq	(%r15,%rdi), %rdi
//X8664-NEXT: 	stosq	%rax, %es:(%rdi)
//X8664-NEXT: 	.bundle_unlock


	rep cmpsq (%rdi), (%rsi)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	leaq	(%r15,%rdi), %rdi
//X8664-NEXT: 	movl	%esi, %esi
//X8664-NEXT: 	leaq	(%r15,%rsi), %rsi
//X8664-NEXT: 	rep
//X8664-NEXT: 	cmpsq	%es:(%rdi), (%rsi)
//X8664-NEXT: 	.bundle_unlock

	rep movsq (%rsi), (%rdi)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	leaq	(%r15,%rdi), %rdi
//X8664-NEXT: 	movl	%esi, %esi
//X8664-NEXT: 	leaq	(%r15,%rsi), %rsi
//X8664-NEXT: 	rep
//X8664-NEXT: 	movsq	(%rsi), %es:(%rdi)
//X8664-NEXT: 	.bundle_unlock

	rep stosq %rax, (%rdi)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	leaq	(%r15,%rdi), %rdi
//X8664-NEXT: 	rep
//X8664-NEXT: 	stosq	%rax, %es:(%rdi)
//X8664-NEXT: 	.bundle_unlock
