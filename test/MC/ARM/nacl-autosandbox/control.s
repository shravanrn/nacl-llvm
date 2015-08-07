// RUN: llvm-mc -nacl-enable-auto-sandboxing -filetype asm -triple armv7-unknown-nacl %s 2>/dev/null | FileCheck %s

.scratch r11

	mov pc, lr
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	lr, lr, #-1073741809
//CHECK-NEXT: 	bx	lr
//CHECK-NEXT: 	.bundle_unlock

	mov pc, r0
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741809
//CHECK-NEXT: 	bx	r0
//CHECK-NEXT: 	.bundle_unlock

	movne pc, r0
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bicne	r0, r0, #-1073741809
//CHECK-NEXT: 	bxne	r0
//CHECK-NEXT: 	.bundle_unlock


	mvn pc, r0
//CHECK:    mvn	r11, r0
//CHECK-NEXT: 	.bundle_lock
//CHECK-NEXT: 	bic	r11, r11, #-1073741809
//CHECK-NEXT: 	bx	r11
//CHECK-NEXT: 	.bundle_unlock


	pop { pc }
//CHECK:    pop	{r11}
//CHECK-NEXT: 	.bundle_lock
//CHECK-NEXT: 	bic	r11, r11, #-1073741809
//CHECK-NEXT: 	bx	r11
//CHECK-NEXT: 	.bundle_unlock

	popne { pc }
//CHECK:    popne	{r11}
//CHECK-NEXT: 	.bundle_lock
//CHECK-NEXT: 	bicne	r11, r11, #-1073741809
//CHECK-NEXT: 	bxne	r11
//CHECK-NEXT: 	.bundle_unlock


	add pc, pc, #4
//CHECK:    adr	r11, #4
//CHECK-NEXT: 	.bundle_lock
//CHECK-NEXT: 	bic	r11, r11, #-1073741809
//CHECK-NEXT: 	bx	r11
//CHECK-NEXT: 	.bundle_unlock

	addne pc, pc, #4
//CHECK:    adrne	r11, #4
//CHECK-NEXT: 	.bundle_lock
//CHECK-NEXT: 	bicne	r11, r11, #-1073741809
//CHECK-NEXT: 	bxne	r11
//CHECK-NEXT: 	.bundle_unlock


	sub pc, pc, r0
//CHECK:    sub	r11, pc, r0
//CHECK-NEXT: 	.bundle_lock
//CHECK-NEXT: 	bic	r11, r11, #-1073741809
//CHECK-NEXT: 	bx	r11
//CHECK-NEXT: 	.bundle_unlock

	subne pc, pc, r0
//CHECK:    subne	r11, pc, r0
//CHECK-NEXT: 	.bundle_lock
//CHECK-NEXT: 	bicne	r11, r11, #-1073741809
//CHECK-NEXT: 	bxne	r11
//CHECK-NEXT: 	.bundle_unlock
	
