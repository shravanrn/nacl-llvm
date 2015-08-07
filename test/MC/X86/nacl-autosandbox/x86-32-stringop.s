// RUN: llvm-mc -nacl-enable-auto-sandboxing -filetype asm -triple i686-unknown-nacl %s | FileCheck %s --check-prefix=X8632
// RUN: llvm-mc -nacl-enable-auto-sandboxing -filetype asm -triple x86_64-unknown-nacl %s | FileCheck %s --check-prefix=X8664


	cmpsl (%edi), (%esi)
//X8632:    	cmpsl	%es:(%edi), (%esi)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	leaq	(%r15,%rdi), %rdi
//X8664-NEXT: 	movl	%esi, %esi
//X8664-NEXT: 	leaq	(%r15,%rsi), %rsi
//X8664-NEXT: 	cmpsl	%es:(%edi), (%esi)
//X8664-NEXT: 	.bundle_unlock

	movsl (%esi), (%edi)
//X8632:    	movsl	(%esi), %es:(%edi)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	leaq	(%r15,%rdi), %rdi
//X8664-NEXT: 	movl	%esi, %esi
//X8664-NEXT: 	leaq	(%r15,%rsi), %rsi
//X8664-NEXT: 	movsl	(%esi), %es:(%edi)
//X8664-NEXT: 	.bundle_unlock

	stosl %eax, (%edi)
//X8632:    	stosl	%eax, %es:(%edi)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	leaq	(%r15,%rdi), %rdi
//X8664-NEXT: 	stosl	%eax, %es:(%edi)
//X8664-NEXT: 	.bundle_unlock


	rep cmpsl (%edi), (%esi)
//X8632:    	rep
//X8632-NEXT: 	cmpsl	%es:(%edi), (%esi)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	leaq	(%r15,%rdi), %rdi
//X8664-NEXT: 	movl	%esi, %esi
//X8664-NEXT: 	leaq	(%r15,%rsi), %rsi
//X8664-NEXT: 	rep
//X8664-NEXT: 	cmpsl	%es:(%edi), (%esi)
//X8664-NEXT: 	.bundle_unlock

	rep movsl (%esi), (%edi)
//X8632:    	rep
//X8632-NEXT: 	movsl	(%esi), %es:(%edi)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	leaq	(%r15,%rdi), %rdi
//X8664-NEXT: 	movl	%esi, %esi
//X8664-NEXT: 	leaq	(%r15,%rsi), %rsi
//X8664-NEXT: 	rep
//X8664-NEXT: 	movsl	(%esi), %es:(%edi)
//X8664-NEXT: 	.bundle_unlock

	rep stosl %eax, (%edi)
//X8632:    	rep
//X8632-NEXT: 	stosl	%eax, %es:(%edi)
//X8664:    	.bundle_lock
//X8664-NEXT: 	movl	%edi, %edi
//X8664-NEXT: 	leaq	(%r15,%rdi), %rdi
//X8664-NEXT: 	rep
//X8664-NEXT: 	stosl	%eax, %es:(%edi)
//X8664-NEXT: 	.bundle_unlock
