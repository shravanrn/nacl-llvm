// RUN: llvm-mc -nacl-enable-auto-sandboxing -filetype asm -triple x86_64-unknown-nacl %s -sfi-hide-sandbox-base=false | FileCheck %s --check-prefix=X8664
// RUN: llvm-mc -nacl-enable-auto-sandboxing -filetype asm -triple x86_64-unknown-nacl %s | FileCheck %s --check-prefix=HIDEBASE
.scratch %r11
foo:

	jmp foo
//X8664:    	jmp	foo
//HIDEBASE:    	jmp	foo

	jmp *%rax
//X8664:    	.bundle_lock
//X8664-NEXT: 	andl	$-32, %eax
//X8664-NEXT: 	addq	%r15, %rax
//X8664-NEXT: 	jmpq	*%rax
//X8664-NEXT: 	.bundle_unlock

//HIDEBASE:    	 movq	%rax, %r11
//HIDEBASE-NEXT: .bundle_lock
//HIDEBASE-NEXT: andl	$-32, %r11d
//HIDEBASE-NEXT: addq	%r15, %r11
//HIDEBASE-NEXT: jmpq	*%r11
//HIDEBASE-NEXT: .bundle_unlock

	jmp *12(%rsp)
//X8664:    	movq	12(%rsp), %r11
//X8664-NEXT: 	.bundle_lock
//X8664-NEXT: 	andl	$-32, %r11d
//X8664-NEXT: 	addq	%r15, %r11
//X8664-NEXT: 	jmpq	*%r11
//X8664-NEXT: 	.bundle_unlock
	
//HIDEBASE:    	 movq	12(%rsp), %r11
//HIDEBASE-NEXT: .bundle_lock
//HIDEBASE-NEXT: andl	$-32, %r11d
//HIDEBASE-NEXT: addq	%r15, %r11
//HIDEBASE-NEXT: jmpq	*%r11
//HIDEBASE-NEXT: .bundle_unloc

	jmp *131072(%rax, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	movq	(%r15,%r11), %r11
//X8664-NEXT: 	.bundle_unlock
//X8664-NEXT: 	.bundle_lock
//X8664-NEXT: 	andl	$-32, %r11d
//X8664-NEXT: 	addq	%r15, %r11
//X8664-NEXT: 	jmpq	*%r11
//X8664-NEXT: 	.bundle_unlock
	
//HIDEBASE:    	 .bundle_lock
//HIDEBASE-NEXT: leal	131072(%rax,%rdi,8), %r11d
//HIDEBASE-NEXT: movq	(%r15,%r11), %r11
//HIDEBASE-NEXT: .bundle_unlock
//HIDEBASE-NEXT: .bundle_lock
//HIDEBASE-NEXT: andl	$-32, %r11d
//HIDEBASE-NEXT: addq	%r15, %r11
//HIDEBASE-NEXT: jmpq	*%r11
//HIDEBASE-NEXT: .bundle_unlock
