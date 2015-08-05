// RUN: llvm-mc -filetype asm -triple x86_64-unknown-nacl %s -sfi-hide-sandbox-base=false | FileCheck %s --check-prefix=X8664
// RUN: llvm-mc -filetype asm -triple x86_64-unknown-nacl %s | FileCheck %s --check-prefix=HIDEBASE
// RUN: llvm-mc -filetype obj -triple x86_64-unknown-nacl -relocation-model=pic %s | llvm-objdump -disassemble - | FileCheck %s --check-prefix=PIC
.scratch %r11
foo:

	call foo
//X8664:    	callq	foo
//HIDEBASE:	callq 	foo

//PIC: 		leal	25(%rip), %r10d
//PIC-NEXT: 	pushq	%r10
//PIC-NEXT: 	jmp	-14

	
	call *%rax
//X8664:    	 .bundle_lock align_to_end
//X8664-NEXT: 	 andl	$-32, %eax
//X8664-NEXT: 	 addq	%r15, %rax
//X8664-NEXT: 	 callq	*%rax
//X8664-NEXT: 	 .bundle_unlock

//HIDEBASE:    	 movq	%rax, %r11
//HIDEBASE-NEXT: pushq	$.LIndirectCallRetAddr{{[0-9]+}}
//HIDEBASE-NEXT: .bundle_lock
//HIDEBASE-NEXT: andl	$-32, %r11d
//HIDEBASE-NEXT: addq	%r15, %r11
//HIDEBASE-NEXT: jmpq	*%r11
//HIDEBASE-NEXT: .bundle_unlock
//HIDEBASE-NEXT: .align	32, 0x90
//HIDEBASE-NEXT: .LIndirectCallRetAddr{{[0-9]+}}:

//PIC: 		movq	%rax, %r11
//PIC-NEXT: 	leal	22(%rip), %r10d
//PIC-NEXT: 	pushq	%r10
//PIC-NEXT: 	andl	$-32, %r11d
//PIC-NEXT: 	addq	%r15, %r11
//PIC-NEXT: 	jmpq	*%r11

	
	call *12(%rsp)
//X8664:    	 movq	12(%rsp), %r11
//X8664-NEXT: 	 .bundle_lock align_to_end
//X8664-NEXT: 	 andl	$-32, %r11d
//X8664-NEXT: 	 addq	%r15, %r11
//X8664-NEXT: 	 callq	*%r11
//X8664-NEXT: 	 .bundle_unlock

//HIDEBASE:    	 movq	12(%rsp), %r11
//HIDEBASE-NEXT: pushq	$.LIndirectCallRetAddr{{[0-9]+}}
//HIDEBASE-NEXT: .bundle_lock
//HIDEBASE-NEXT: andl	$-32, %r11d
//HIDEBASE-NEXT: addq	%r15, %r11
//HIDEBASE-NEXT: jmpq	*%r11
//HIDEBASE-NEXT: .bundle_unlock
//HIDEBASE-NEXT: .align	32, 0x90
//HIDEBASE-NEXT: .LIndirectCallRetAddr{{[0-9]+}}

//PIC: 		movq	12(%rsp), %r11
//PIC-NEXT: 	leal	20(%rip), %r10d
//PIC-NEXT: 	pushq	%r10
//PIC-NEXT: 	andl	$-32, %r11d
//PIC-NEXT: 	addq	%r15, %r11
//PIC-NEXT: 	jmpq	*%r11

	
	call *131072(%rax, %rdi, 8)
//X8664:    	 .bundle_lock
//X8664-NEXT: 	 leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	 movq	(%r15,%r11), %r11
//X8664-NEXT: 	 .bundle_unlock
//X8664-NEXT: 	 .bundle_lock align_to_end
//X8664-NEXT: 	 andl	$-32, %r11d
//X8664-NEXT: 	 addq	%r15, %r11
//X8664-NEXT: 	 callq	*%r11
//X8664-NEXT: 	 .bundle_unlock

//HIDEBASE:    	 .bundle_lock
//HIDEBASE-NEXT: leal	131072(%rax,%rdi,8), %r11d
//HIDEBASE-NEXT: movq	(%r15,%r11), %r11
//HIDEBASE-NEXT: .bundle_unlock
//HIDEBASE-NEXT: pushq	$.LIndirectCallRetAddr{{[0-9]+}}
//HIDEBASE-NEXT: .bundle_lock
//HIDEBASE-NEXT: andl	$-32, %r11d
//HIDEBASE-NEXT: addq	%r15, %r11
//HIDEBASE-NEXT: jmpq	*%r11
//HIDEBASE-NEXT: .bundle_unlock
//HIDEBASE-NEXT: .align	32, 0x90
//HIDEBASE-NEXT: .LIndirectCallRetAddr{{[0-9]+}}:

//PIC: 		leal	131072(%rax,%rdi,8), %r11d
//PIC-NEXT: 	movq	(%r15,%r11), %r11
//PIC-NEXT: 	leal	13(%rip), %r10d
//PIC-NEXT: 	pushq	%r10
//PIC-NEXT: 	andl	$-32, %r11d
//PIC-NEXT: 	addq	%r15, %r11
//PIC-NEXT: 	jmpq	*%r11
