// RUN: llvm-mc -nacl-enable-auto-sandboxing -filetype asm -triple x86_64-unknown-nacl %s | FileCheck %s

.scratch %r11
	// Floating point movement

	movss %xmm0, %xmm1
//CHECK:    	movss	%xmm0, %xmm1            

	movss 12(%rsp), %xmm0
//CHECK:    	movss	12(%rsp), %xmm0         

	movss 131072(%rax, %rdi, 8), %xmm0
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	movss	(%r15,%r11), %xmm0      
//CHECK-NEXT: 	.bundle_unlock

	movss %xmm0, 12(%rsp)
//CHECK:    	movss	%xmm0, 12(%rsp)

	movss %xmm0, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	movss	%xmm0, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock


	movaps %xmm0, %xmm1
//CHECK:    	movaps	%xmm0, %xmm1

	movaps 12(%rsp), %xmm0
//CHECK:    	movaps	12(%rsp), %xmm0

	movaps 131072(%rax, %rdi, 8), %xmm0
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	movaps	(%r15,%r11), %xmm0
//CHECK-NEXT: 	.bundle_unlock

	movaps %xmm0, 12(%rsp)
//CHECK:    	movaps	%xmm0, 12(%rsp)

	movaps %xmm0, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	movaps	%xmm0, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock


	vmovaps %xmm0, %xmm1
//CHECK:    	vmovaps	%xmm0, %xmm1

	vmovaps 12(%rsp), %xmm0
//CHECK:    	vmovaps	12(%rsp), %xmm0

	vmovaps 131072(%rax, %rdi, 8), %xmm0
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	vmovaps	(%r15,%r11), %xmm0
//CHECK-NEXT: 	.bundle_unlock

	vmovaps %xmm0, 12(%rsp)
//CHECK:    	vmovaps	%xmm0, 12(%rsp)

	vmovaps %xmm0, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	vmovaps	%xmm0, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock


	vmovaps %ymm0, %ymm1
//CHECK:    	vmovaps	%ymm0, %ymm1

	vmovaps 12(%rsp), %ymm0
//CHECK:    	vmovaps	12(%rsp), %ymm0

	vmovaps 131072(%rax, %rdi, 8), %ymm0
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	vmovaps	(%r15,%r11), %ymm0
//CHECK-NEXT: 	.bundle_unlock

	vmovaps %ymm0, 12(%rsp)
//CHECK:    	vmovaps	%ymm0, 12(%rsp)

	vmovaps %ymm0, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	vmovaps	%ymm0, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock

	// Floating point arithmetic/logic

	addss %xmm0, %xmm1
//CHECK:    	addss	%xmm0, %xmm1

	addss 12(%rsp), %xmm0
//CHECK:    	addss	12(%rsp), %xmm0

	addss 131072(%rax, %rdi, 8), %xmm0
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	addss	(%r15,%r11), %xmm0
//CHECK-NEXT: 	.bundle_unlock


	vaddss %xmm0, %xmm1, %xmm2
//CHECK:    	vaddss	%xmm0, %xmm1, %xmm2

	vaddss 12(%rsp), %xmm0, %xmm1
//CHECK:    	vaddss	12(%rsp), %xmm0, %xmm1

	vaddss 131072(%rax, %rdi, 8), %xmm0, %xmm1
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	vaddss	(%r15,%r11), %xmm0, %xmm1
//CHECK-NEXT: 	.bundle_unlock


	addps %xmm0, %xmm1
//CHECK:    	addps	%xmm0, %xmm1

	addps 12(%rsp), %xmm0
//CHECK:    	addps	12(%rsp), %xmm0

	addps 131072(%rax, %rdi, 8), %xmm0
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	addps	(%r15,%r11), %xmm0
//CHECK-NEXT: 	.bundle_unlock


	vaddps %xmm0, %xmm1, %xmm2
//CHECK:    	vaddps	%xmm0, %xmm1, %xmm2

	vaddps 12(%rsp), %xmm0, %xmm1
//CHECK:    	vaddps	12(%rsp), %xmm0, %xmm1

	vaddps 131072(%rax, %rdi, 8), %xmm0, %xmm1
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	vaddps	(%r15,%r11), %xmm0, %xmm1
//CHECK-NEXT: 	.bundle_unlock


	vaddps %ymm0, %ymm1, %ymm2
//CHECK:    	vaddps	%ymm0, %ymm1, %ymm2

	vaddps 12(%rsp), %ymm0, %ymm1
//CHECK:    	vaddps	12(%rsp), %ymm0, %ymm1

	vaddps 131072(%rax, %rdi, 8), %ymm0, %ymm1
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	vaddps	(%r15,%r11), %ymm0, %ymm1
//CHECK-NEXT: 	.bundle_unlock

	// Floating point compare

	cmpss $12, %xmm0, %xmm1
//CHECK:    	cmpss	$12, %xmm0, %xmm1

	cmpss $12, 12(%rsp), %xmm0
//CHECK:    	cmpss	$12, 12(%rsp), %xmm0

	cmpss $12, 131072(%rax, %rdi, 8), %xmm0
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	cmpss	$12, (%r15,%r11), %xmm0
//CHECK-NEXT: 	.bundle_unlock


	vcmpss $12, %xmm0, %xmm1, %xmm2
//CHECK:    	vcmpss	$12, %xmm0, %xmm1, %xmm2

	vcmpss $12, 12(%rsp), %xmm0, %xmm1
//CHECK:    	vcmpss	$12, 12(%rsp), %xmm0, %xmm1

	vcmpss $12, 131072(%rax, %rdi, 8), %xmm0, %xmm1
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	vcmpss	$12, (%r15,%r11), %xmm0, %xmm1
//CHECK-NEXT: 	.bundle_unlock


	cmpps $12, %xmm0, %xmm1
//CHECK:    	cmpps	$12, %xmm0, %xmm1

	cmpps $12, 12(%rsp), %xmm0
//CHECK:    	cmpps	$12, 12(%rsp), %xmm0

	cmpps $12, 131072(%rax, %rdi, 8), %xmm0
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	cmpps	$12, (%r15,%r11), %xmm0
//CHECK-NEXT: 	.bundle_unlock


	vcmpps $12, %xmm0, %xmm1, %xmm2
//CHECK:    	vcmpps	$12, %xmm0, %xmm1, %xmm2

	vcmpps $12, 12(%rsp), %xmm0, %xmm1
//CHECK:    	vcmpps	$12, 12(%rsp), %xmm0, %xmm1

	vcmpps $12, 131072(%rax, %rdi, 8), %xmm0, %xmm1
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	vcmpps	$12, (%r15,%r11), %xmm0, %xmm1
//CHECK-NEXT: 	.bundle_unlock

	
	// Data shuffle and unpacking

	shufps $12, %xmm0, %xmm1
//CHECK:    	shufps	$12, %xmm0, %xmm1       

	shufps $12, 12(%rsp), %xmm1
//CHECK:    	shufps	$12, 12(%rsp), %xmm1    

	shufps $12, 131072(%rax, %rdi, 8), %xmm1
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	shufps	$12, (%r15,%r11), %xmm1 
//CHECK-NEXT: 	.bundle_unlock


	vshufps $12, %xmm0, %xmm1, %xmm2
//CHECK:    	vshufps	$12, %xmm0, %xmm1, %xmm2 

	vshufps $12, 12(%rsp), %xmm0, %xmm1
//CHECK:    	vshufps	$12, 12(%rsp), %xmm0, %xmm1 

	vshufps $12, 131072(%rax, %rdi, 8), %xmm0, %xmm1
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	vshufps	$12, (%r15,%r11), %xmm0, %xmm1 
//CHECK-NEXT: 	.bundle_unlock


	vshufps $12, %ymm0, %ymm1, %ymm2
//CHECK:    	vshufps	$12, %ymm0, %ymm1, %ymm2 

	vshufps $12, 12(%rsp), %ymm0, %ymm1
//CHECK:    	vshufps	$12, 12(%rsp), %ymm0, %ymm1 

	vshufps $12, 131072(%rax, %rdi, 8), %ymm0, %ymm1
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	vshufps	$12, (%r15,%r11), %ymm0, %ymm1 
//CHECK-NEXT: 	.bundle_unlock


	unpckhpd %xmm0, %xmm1
//CHECK:    	unpckhpd	%xmm0, %xmm1    

	unpckhpd 12(%rsp), %xmm1
//CHECK:    	unpckhpd	12(%rsp), %xmm1 

	unpckhpd 131072(%rax, %rdi, 8), %xmm1
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	unpckhpd	(%r15,%r11), %xmm1 
//CHECK-NEXT: 	.bundle_unlock


	vunpckhpd %xmm0, %xmm1, %xmm2
//CHECK:    	vunpckhpd	%xmm0, %xmm1, %xmm2 

	vunpckhpd 12(%rsp), %xmm0, %xmm1
//CHECK:    	vunpckhpd	12(%rsp), %xmm0, %xmm1 

	vunpckhpd 131072(%rax, %rdi, 8), %xmm0, %xmm1
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	vunpckhpd	(%r15,%r11), %xmm0, %xmm1 
//CHECK-NEXT: 	.bundle_unlock


	vunpckhpd %ymm0, %ymm1, %ymm2
//CHECK:    	vunpckhpd	%ymm0, %ymm1, %ymm2 

	vunpckhpd 12(%rsp), %ymm0, %ymm1
//CHECK:    	vunpckhpd	12(%rsp), %ymm0, %ymm1 

	vunpckhpd 131072(%rax, %rdi, 8), %ymm0, %ymm1
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	vunpckhpd	(%r15,%r11), %ymm0, %ymm1 
//CHECK-NEXT: 	.bundle_unlock
	
	// Data type conversion

	cvtsi2ssq %rax, %xmm0
//CHECK:    	cvtsi2ssq	%rax, %xmm0

	cvtsi2ssq 12(%rsp), %xmm0
//CHECK:    	cvtsi2ssq	12(%rsp), %xmm0

	cvtsi2ssq 131072(%rax, %rdi, 8), %xmm0
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	cvtsi2ssq	(%r15,%r11), %xmm0
//CHECK-NEXT: 	.bundle_unlock


	vcvtsi2ssq %rax, %xmm0, %xmm1
//CHECK:    	vcvtsi2ssq	%rax, %xmm0, %xmm1

	vcvtsi2ssq 12(%rsp), %xmm0, %xmm1
//CHECK:    	vcvtsi2ssq	12(%rsp), %xmm0, %xmm1

	vcvtsi2ssq 131072(%rax, %rdi, 8), %xmm0, %xmm1
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	vcvtsi2ssq	(%r15,%r11), %xmm0, %xmm1
//CHECK-NEXT: 	.bundle_unlock


	cvtpi2ps 12(%rsp), %xmm0
//CHECK:    	cvtpi2ps	12(%rsp), %xmm0

	cvtpi2ps 131072(%rax, %rdi, 8), %xmm0
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	cvtpi2ps	(%r15,%r11), %xmm0
//CHECK-NEXT: 	.bundle_unlock

	// Integer instructions

	pavgb %mm0, %mm1
//CHECK:    	pavgb	%mm0, %mm1

	pavgb 12(%rsp), %mm0
//CHECK:    	pavgb	12(%rsp), %mm0

	pavgb 131072(%rax, %rdi, 8), %mm0
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	pavgb	(%r15,%r11), %mm0
//CHECK-NEXT: 	.bundle_unlock


	vpavgb %xmm0, %xmm1, %xmm2
//CHECK:    	vpavgb	%xmm0, %xmm1, %xmm2

	vpavgb 12(%rsp), %xmm0, %xmm2
//CHECK:    	vpavgb	12(%rsp), %xmm0, %xmm2

	vpavgb 131072(%rax, %rdi, 8), %xmm0, %xmm2
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	vpavgb	(%r15,%r11), %xmm0, %xmm2
//CHECK-NEXT: 	.bundle_unlock


	vpavgb %ymm0, %ymm1, %ymm2
//CHECK:    	vpavgb	%ymm0, %ymm1, %ymm2

	vpavgb 12(%rsp), %ymm0, %ymm2
//CHECK:    	vpavgb	12(%rsp), %ymm0, %ymm2

	vpavgb 131072(%rax, %rdi, 8), %ymm0, %ymm2
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	vpavgb	(%r15,%r11), %ymm0, %ymm2
//CHECK-NEXT: 	.bundle_unlock


	pextrw $12, %xmm0, %rax
//CHECK:    	pextrw	$12, %xmm0, %eax

	pextrw $12, %xmm0, 12(%rsp)
//CHECK:    	pextrw	$12, %xmm0, 12(%rsp)

	pextrw $12, %xmm0, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	pextrw	$12, %xmm0, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock


	vpextrw $12, %xmm0, %rax
//CHECK:    	vpextrw	$12, %xmm0, %eax

	vpextrw $12, %xmm0, 12(%rsp)
//CHECK:    	vpextrw	$12, %xmm0, 12(%rsp)

	vpextrw $12, %xmm0, 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	vpextrw	$12, %xmm0, (%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock


	pmovmskb %xmm0, %rax
//CHECK:    	pmovmskb	%xmm0, %eax

	vpmovmskb %xmm0, %rax
//CHECK:    	vpmovmskb	%xmm0, %eax

	vpmovmskb %ymm0, %rax
//CHECK:    	vpmovmskb	%ymm0, %eax

	// Other instructions

	ldmxcsr 12(%rsp)
//CHECK:    	ldmxcsr	12(%rsp)

	ldmxcsr 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	ldmxcsr	(%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock

	vldmxcsr 12(%rsp)
//CHECK:    	vldmxcsr	12(%rsp)

	vldmxcsr 131072(%rax, %rdi, 8)
//CHECK:    	.bundle_lock
//CHECK-NEXT: 	leal	131072(%rax,%rdi,8), %r11d
//CHECK-NEXT: 	vldmxcsr	(%r15,%r11)
//CHECK-NEXT: 	.bundle_unlock
	
	
