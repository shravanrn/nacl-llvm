// RUN: llvm-mc -nacl-enable-auto-sandboxing -filetype asm -triple x86_64-unknown-nacl %s | FileCheck %s --check-prefix=X8664
.scratch %r11

	ret
//X8664:    	popq	%r11
//X8664-NEXT: 	.bundle_lock
//X8664-NEXT: 	andl	$-32, %r11d
//X8664-NEXT: 	addq	%r15, %r11
//X8664-NEXT: 	jmpq	*%r11
//X8664-NEXT: 	.bundle_unlock

	ret $12
//X8664:    	popq	%r11
//X8664-NEXT: 	.bundle_lock
//X8664-NEXT: 	addl	$12, %esp
//X8664-NEXT: 	leaq	(%rsp,%r15), %rsp
//X8664-NEXT: 	.bundle_unlock
//X8664-NEXT: 	.bundle_lock
//X8664-NEXT: 	andl	$-32, %r11d
//X8664-NEXT: 	addq	%r15, %r11
//X8664-NEXT: 	jmpq	*%r11
//X8664-NEXT: 	.bundle_unlock
