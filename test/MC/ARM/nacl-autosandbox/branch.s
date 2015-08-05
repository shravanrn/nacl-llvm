// RUN: llvm-mc -filetype asm -triple armv7-unknown-nacl %s | FileCheck %s

foo:	

	b foo
//CHECK:    b	foo

	bx r0
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741809
//CHECK-NEXT: 	bx	r0
//CHECK-NEXT: 	.bundle_unlock

	bx sp
//CHECK:    bx	sp

	bx pc
//CHECK:    bx	pc


	bne foo
//CHECK:    bne	foo

	bxne r0
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bicne	r0, r0, #-1073741809
//CHECK-NEXT: 	bxne	r0
//CHECK-NEXT: 	.bundle_unlock

	bxne sp
//CHECK:    bxne	sp

	bxne pc
//CHECK:    bxne	pc
