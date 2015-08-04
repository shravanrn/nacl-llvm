// RUN: llvm-mc -filetype asm -triple i386-unknown-nacl %s | FileCheck %s -check-prefix=X32
// RUN: llvm-mc -filetype asm -triple x86_64-unknown-nacl %s | FileCheck %s -check-prefix=X64


	cmpsl (%edi), (%esi)
//X32:    	cmpsl	%es:(%edi), (%esi)
//X64:    	.bundle_lock
//X64-NEXT: 	movl	%edi, %edi
//X64-NEXT: 	leaq	(%r15,%edi), %edi
//X64-NEXT: 	movl	%esi, %esi
//X64-NEXT: 	leaq	(%r15,%esi), %esi
//X64-NEXT: 	cmpsl	%es:(%edi), (%esi)
//X64-NEXT: 	.bundle_unlock

	movsl (%esi), (%edi)
//X32:    	movsl	(%esi), %es:(%edi)
//X64:    	.bundle_lock
//X64-NEXT: 	movl	%edi, %edi
//X64-NEXT: 	leaq	(%r15,%edi), %edi
//X64-NEXT: 	movl	%esi, %esi
//X64-NEXT: 	leaq	(%r15,%esi), %esi
//X64-NEXT: 	movsl	(%esi), %es:(%edi)
//X64-NEXT: 	.bundle_unlock

	stosl %eax, (%edi)
//X32:    	stosl	%eax, %es:(%edi)
//X64:    	.bundle_lock
//X64-NEXT: 	movl	%edi, %edi
//X64-NEXT: 	leaq	(%r15,%edi), %edi
//X64-NEXT: 	stosl	%eax, %es:(%edi)
//X64-NEXT: 	.bundle_unlock


	cmpsq (%rdi), (%rsi)
//X64:    	.bundle_lock
//X64-NEXT: 	movl	%edi, %edi
//X64-NEXT: 	leaq	(%r15,%rdi), %rdi
//X64-NEXT: 	movl	%esi, %esi
//X64-NEXT: 	leaq	(%r15,%rsi), %rsi
//X64-NEXT: 	cmpsq	%es:(%rdi), (%rsi)
//X64-NEXT: 	.bundle_unlock

	movsq (%rsi), (%rdi)
//X64:    	.bundle_lock
//X64-NEXT: 	movl	%edi, %edi
//X64-NEXT: 	leaq	(%r15,%rdi), %rdi
//X64-NEXT: 	movl	%esi, %esi
//X64-NEXT: 	leaq	(%r15,%rsi), %rsi
//X64-NEXT: 	movsq	(%rsi), %es:(%rdi)
//X64-NEXT: 	.bundle_unlock

	stosq %rax, (%rdi)
//X64:    	.bundle_lock
//X64-NEXT: 	movl	%edi, %edi
//X64-NEXT: 	leaq	(%r15,%rdi), %rdi
//X64-NEXT: 	stosq	%rax, %es:(%rdi)
//X64-NEXT: 	.bundle_unlock


	rep cmpsq (%rdi), (%rsi)
//X64:    	.bundle_lock
//X64-NEXT: 	movl	%edi, %edi
//X64-NEXT: 	leaq	(%r15,%rdi), %rdi
//X64-NEXT: 	movl	%esi, %esi
//X64-NEXT: 	leaq	(%r15,%rsi), %rsi
//X64-NEXT: 	rep
//X64-NEXT: 	cmpsq	%es:(%rdi), (%rsi)
//X64-NEXT: 	.bundle_unlock

	rep movsq (%rsi), (%rdi)
//X64:    	.bundle_lock
//X64-NEXT: 	movl	%edi, %edi
//X64-NEXT: 	leaq	(%r15,%rdi), %rdi
//X64-NEXT: 	movl	%esi, %esi
//X64-NEXT: 	leaq	(%r15,%rsi), %rsi
//X64-NEXT: 	rep
//X64-NEXT: 	movsq	(%rsi), %es:(%rdi)
//X64-NEXT: 	.bundle_unlock

	rep stosq %rax, (%rdi)
//X64:    	.bundle_lock
//X64-NEXT: 	movl	%edi, %edi
//X64-NEXT: 	leaq	(%r15,%rdi), %rdi
//X64-NEXT: 	rep
//X64-NEXT: 	stosq	%rax, %es:(%rdi)
//X64-NEXT: 	.bundle_unlock
