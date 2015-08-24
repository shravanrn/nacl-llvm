// RUN: llvm-mc -nacl-enable-auto-sandboxing -filetype asm -triple armv7-unknown-nacl %s | FileCheck %s

	mov sp, r1
//CHECK:    .bundle_lock
//CHECK-NEXT: 	mov	sp, r1
//CHECK-NEXT: 	bic	sp, sp, #-1073741824
//CHECK-NEXT: 	.bundle_unlock

	movne sp, r1
//CHECK:    .bundle_lock
//CHECK-NEXT: 	movne	sp, r1
//CHECK-NEXT: 	bicne	sp, sp, #-1073741824
//CHECK-NEXT: 	.bundle_unlock


	add sp, sp, #4
//CHECK:    .bundle_lock
//CHECK-NEXT: 	add	sp, sp, #4
//CHECK-NEXT: 	bic	sp, sp, #-1073741824
//CHECK-NEXT: 	.bundle_unlock

	addne sp, sp, #4
//CHECK:    .bundle_lock
//CHECK-NEXT: 	addne	sp, sp, #4
//CHECK-NEXT: 	bicne	sp, sp, #-1073741824
//CHECK-NEXT: 	.bundle_unlock

	add sp, sp, r1
//CHECK:    .bundle_lock
//CHECK-NEXT: 	add	sp, sp, r1
//CHECK-NEXT: 	bic	sp, sp, #-1073741824
//CHECK-NEXT: 	.bundle_unlock

	addne sp, sp, r1
//CHECK:    .bundle_lock
//CHECK-NEXT: 	addne	sp, sp, r1
//CHECK-NEXT: 	bicne	sp, sp, #-1073741824
//CHECK-NEXT: 	.bundle_unlock


	add sp, r1, r2, lsl #8
//CHECK:    .bundle_lock
//CHECK-NEXT: 	add	sp, r1, r2, lsl #8
//CHECK-NEXT: 	bic	sp, sp, #-1073741824
//CHECK-NEXT: 	.bundle_unlock

	addne sp, r1, r2, lsl #8
//CHECK:    .bundle_lock
//CHECK-NEXT: 	addne	sp, r1, r2, lsl #8
//CHECK-NEXT: 	bicne	sp, sp, #-1073741824
//CHECK-NEXT: 	.bundle_unlock


	pop { r0 }
//CHECK-NOT: bic
//CHECK:    pop	{r0}

	popne { r0 }
//CHECK-NOT: bic
//CHECK:    popne	{r0}

	push { r0 }
//CHECK-NOT: bic
//CHECK:    push	{r0}

	pushne { r0 }
//CHECK:    pushne	{r0}


	pop { r0 , r1, r2 ,r3 }
//CHECK-NOT: bic
//CHECK:    pop	{r0, r1, r2, r3}

	popne { r0, r1, r2, r3 }
//CHECK-NOT: bic
//CHECK:    popne	{r0, r1, r2, r3}

	push { r0, r1, r2, r3 }
//CHECK-NOT: bic
//CHECK:    push	{r0, r1, r2, r3}

	pushne { r0, r1, r2, r3 }
//CHECK-NOT: bic
//CHECK:    pushne	{r0, r1, r2, r3}


	vpop { d0 }
//CHECK-NOT: bic
//CHECK:    vpop	{d0}

	vpopne { d0 }
//CHECK-NOT: bic
//CHECK:    vpopne	{d0}

	vpush { d0 }
//CHECK-NOT: bic
//CHECK:    vpush	{d0}

	vpushne { d0 }
//CHECK-NOT: bic
//CHECK:    vpushne	{d0}


	vpop { d0 , d1, d2 ,d3 }
//CHECK-NOT: bic
//CHECK:    vpop	{d0, d1, d2, d3}

	vpopne { d0, d1, d2, d3 }
//CHECK-NOT: bic
//CHECK:    vpopne	{d0, d1, d2, d3}

	vpush { d0, d1, d2, d3 }
//CHECK-NOT: bic
//CHECK:    vpush	{d0, d1, d2, d3}

	vpushne { d0, d1, d2, d3 }
//CHECK-NOT: bic
//CHECK:    vpushne	{d0, d1, d2, d3}


	sub sp, sp, #4
//CHECK:    .bundle_lock
//CHECK-NEXT: 	sub	sp, sp, #4
//CHECK-NEXT: 	bic	sp, sp, #-1073741824
//CHECK-NEXT: 	.bundle_unlock

	mul sp, sp, sp
//CHECK:    .bundle_lock
//CHECK-NEXT: 	mul	sp, sp, sp
//CHECK-NEXT: 	bic	sp, sp, #-1073741824
//CHECK-NEXT: 	.bundle_unlock

	and sp, r0, #128
//CHECK:    .bundle_lock
//CHECK-NEXT: 	and	sp, r0, #128
//CHECK-NEXT: 	bic	sp, sp, #-1073741824
//CHECK-NEXT: 	.bundle_unlock

	bic sp, sp, #31
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	sp, sp, #31
//CHECK-NEXT: 	bic	sp, sp, #-1073741824
//CHECK-NEXT: 	.bundle_unlock


	ldr sp, [r0]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	.bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	ldr	sp, [r0]
//CHECK-NEXT: 	.bundle_unlock
//CHECK-NEXT: 	bic	sp, sp, #-1073741824
//CHECK-NEXT: 	.bundle_unlock

	ldrd r12, sp, [r0]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	.bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	ldrd	r12, sp, [r0]
//CHECK-NEXT: 	.bundle_unlock
//CHECK-NEXT: 	bic	sp, sp, #-1073741824
//CHECK-NEXT: 	.bundle_unlock

	ldmia r0, {r1, sp}
//CHECK:    .bundle_lock
//CHECK-NEXT: 	.bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	ldm	r0, {r1, sp}
//CHECK-NEXT: 	.bundle_unlock
//CHECK-NEXT: 	bic	sp, sp, #-1073741824
//CHECK-NEXT: 	.bundle_unlock


	str sp, [r0]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	str	sp, [r0]
//CHECK-NEXT: 	.bundle_unlock

	strd r12, sp, [r0]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	strd	r12, sp, [r0]
//CHECK-NEXT: 	.bundle_unlock

	stmia r0, {r1, sp}
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	stm	r0, {r1, sp}
//CHECK-NEXT: 	.bundle_unlock

	
	
