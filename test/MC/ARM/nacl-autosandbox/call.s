// RUN: llvm-mc -nacl-enable-auto-sandboxing -filetype asm -triple armv7-unknown-nacl %s | FileCheck %s

foo:	

	bl foo
//CHECK:    bl	foo

	blx r0
//CHECK:    .bundle_lock align_to_end
//CHECK-NEXT: 	bic	r0, r0, #-1073741809
//CHECK-NEXT: 	blx	r0
//CHECK-NEXT: 	.bundle_unlock

	blx sp
//CHECK:    blx	sp

	blx pc
//CHECK:    blx	pc


	blne foo
//CHECK:    blne	foo

	blxne f0
//CHECK:    blx	f0

	blxne sp
//CHECK:    blxne	sp

	blxne pc
//CHECK:    blxne	pc
