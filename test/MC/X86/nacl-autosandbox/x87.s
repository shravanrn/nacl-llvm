// RUN: llvm-mc -nacl-enable-auto-sandboxing -filetype asm -triple x86_64-unknown-nacl %s | FileCheck %s --check-prefix=X8664
.scratch %r11


	fabs
//X8664:    	fabs

	fcos
//X8664:    	fcos

	fsqrt
//X8664:    	fsqrt

	fprem
//X8664:    	fprem

	fxtract
//X8664:    	fxtract

	fxch %st(3)
//X8664:    	fxch	%st(3)


	faddp
//X8664:    	faddp	%st(1)

	fadds 12(%rsp)
//X8664:    	fadds	12(%rsp)

	fadds 131072(%rax, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	fadds	(%r15,%r11)
//X8664-NEXT: 	.bundle_unlock

	fadd %st(0),%st(3)
//X8664:    	fadd	%st(0), %st(3)


	fmulp
//X8664:    	fmulp	%st(1)

	fmuls 12(%rsp)
//X8664:    	fmuls	12(%rsp)

	fmuls 131072(%rax, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	fmuls	(%r15,%r11)
//X8664-NEXT: 	.bundle_unlock

	fmul %st(0),%st(3)
//X8664:    	fmul	%st(0), %st(3)


	flds 12(%rsp)
//X8664:    	flds	12(%rsp)

	flds 131072(%rax, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	flds	(%r15,%r11)
//X8664-NEXT: 	.bundle_unlock

	fld %st(3)
//X8664:    	fld	%st(3)


	fstps 12(%rsp)
//X8664:    	fstps	12(%rsp)

	fstps 131072(%rax, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	fstps	(%r15,%r11)
//X8664-NEXT: 	.bundle_unlock

	fstp %st(3)
//X8664:    	fstp	%st(3)


	fnsave 12(%rsp)
//X8664:    	fnsave	12(%rsp)

	fnsave 131072(%rax, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	fnsave	(%r15,%r11)
//X8664-NEXT: 	.bundle_unlock

	fxsave 12(%rsp)
//X8664:    	fxsave	12(%rsp)

	fxsave 131072(%rax, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	fxsave	(%r15,%r11)
//X8664-NEXT: 	.bundle_unlock

	frstor 12(%rsp)
//X8664:    	frstor	12(%rsp)

	frstor 131072(%rax, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	frstor	(%r15,%r11)
//X8664-NEXT: 	.bundle_unlock

	fxrstor 12(%rsp)
//X8664:    	fxrstor	12(%rsp)

	fxrstor 131072(%rax, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	fxrstor	(%r15,%r11)
//X8664-NEXT: 	.bundle_unlock

	fstenv 12(%rsp)
//X8664:    	wait
//X8664-NEXT: 	fnstenv	12(%rsp)

	fstenv 131072(%rax, %rdi, 8)
//X8664:    	wait
//X8664-NEXT: 	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	fnstenv	(%r15,%r11)
//X8664-NEXT: 	.bundle_unlock

	fnstenv 12(%rsp)
//X8664:    	fnstenv	12(%rsp)

	fnstenv 131072(%rax, %rdi, 8)
//X8664:    	.bundle_lock
//X8664-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//X8664-NEXT: 	fnstenv	(%r15,%r11)
//X8664-NEXT: 	.bundle_unlock


	fnstsw %ax
//X8664:    	fnstsw	%ax



	
	
