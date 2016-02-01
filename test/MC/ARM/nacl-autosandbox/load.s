// RUN: llvm-mc -nacl-enable-auto-sandboxing -filetype asm -triple armv7-unknown-nacl %s 2>/dev/null | FileCheck %s

// No scratch registers should be needed for loads.

	ldmia r0, { r1, r2 }
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	ldm	r0, {r1, r2}
//CHECK-NEXT: 	.bundle_unlock

	ldmiane r0, { r1, r2 }
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bicne	r0, r0, #-1073741824
//CHECK-NEXT: 	ldmne	r0, {r1, r2}
//CHECK-NEXT: 	.bundle_unlock

	ldmda r0, { r1, r2 }
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	ldmda	r0, {r1, r2}
//CHECK-NEXT: 	.bundle_unlock

	ldmdane r0, { r1, r2 }
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bicne	r0, r0, #-1073741824
//CHECK-NEXT: 	ldmdane	r0, {r1, r2}
//CHECK-NEXT: 	.bundle_unlock


	ldr r0, [pc]
//CHECK:    ldr	r0, [pc]

	ldr r0, [pc, #4]
//CHECK:    ldr	r0, [pc, #4]

	ldr r0, [pc, r2]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	add	r0, pc, r2
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	ldr	r0, [r0]
//CHECK-NEXT: 	.bundle_unlock

	ldr r0, [pc, r2, lsl #8]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	add	r0, pc, r2, lsl #8
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	ldr	r0, [r0]
//CHECK-NEXT: 	.bundle_unlock

	ldr r0, [sp]
//CHECK:    ldr	r0, [sp]

	ldr r0, [sp, #4]
//CHECK:    ldr	r0, [sp, #4]

	ldr r0, [sp, #4]!
//CHECK:    ldr	r0, [sp, #4]!

	ldr r0, [sp, r2]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	add	r0, sp, r2
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	ldr	r0, [r0]
//CHECK-NEXT: 	.bundle_unlock

	ldr r0, [sp, r2]!
//CHECK:    .bundle_lock
//CHECK-NEXT: 	add	sp, sp, r2
//CHECK-NEXT: 	bic	sp, sp, #-1073741824
//CHECK-NEXT: 	ldr	r0, [sp]
//CHECK-NEXT: 	.bundle_unlock

	ldr r0, [sp], r2
//CHECK:    .bundle_lock
//CHECK-NEXT: 	ldr	r0, [sp], r2
//CHECK-NEXT: 	bic	sp, sp, #-1073741824
//CHECK-NEXT: 	.bundle_unlock

	ldr r0, [sp, r2, lsl #8]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	add	r0, sp, r2, lsl #8
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	ldr	r0, [r0]
//CHECK-NEXT: 	.bundle_unlock

	ldr r0, [sp, r2, lsl #8]!
//CHECK:    .bundle_lock
//CHECK-NEXT: 	add	sp, sp, r2, lsl #8
//CHECK-NEXT: 	bic	sp, sp, #-1073741824
//CHECK-NEXT: 	ldr	r0, [sp]
//CHECK-NEXT: 	.bundle_unlock

	ldr r0, [sp], r2, lsl #8
//CHECK:    .bundle_lock
//CHECK-NEXT: 	ldr	r0, [sp], r2, lsl #8
//CHECK-NEXT: 	bic	sp, sp, #-1073741824
//CHECK-NEXT: 	.bundle_unlock

	ldr r0, [r1]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r1, r1, #-1073741824
//CHECK-NEXT: 	ldr	r0, [r1]
//CHECK-NEXT: 	.bundle_unlock

	ldr r0, [r1, #4]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r1, r1, #-1073741824
//CHECK-NEXT: 	ldr	r0, [r1, #4]
//CHECK-NEXT: 	.bundle_unlock

	ldr r0, [r1, #4]!
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r1, r1, #-1073741824
//CHECK-NEXT: 	ldr	r0, [r1, #4]!
//CHECK-NEXT: 	.bundle_unlock

	ldr r0, [r1, r2]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	add	r0, r1, r2
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	ldr	r0, [r0]
//CHECK-NEXT: 	.bundle_unlock

	ldr r0, [r1, r2]!
//CHECK:    .bundle_lock
//CHECK-NEXT: 	add	r1, r1, r2
//CHECK-NEXT: 	bic	r1, r1, #-1073741824
//CHECK-NEXT: 	ldr	r0, [r1]
//CHECK-NEXT: 	.bundle_unlock

	ldr r0, [r1], r2
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r1, r1, #-1073741824
//CHECK-NEXT: 	ldr	r0, [r1], r2
//CHECK-NEXT: 	.bundle_unlock

	ldr r0, [r1, r2, lsl #8]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	add	r0, r1, r2, lsl #8
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	ldr	r0, [r0]
//CHECK-NEXT: 	.bundle_unlock

	ldr r0, [r1, r2, lsl #8]!
//CHECK:    .bundle_lock
//CHECK-NEXT: 	add	r1, r1, r2, lsl #8
//CHECK-NEXT: 	bic	r1, r1, #-1073741824
//CHECK-NEXT: 	ldr	r0, [r1]
//CHECK-NEXT: 	.bundle_unlock

	ldr r0, [r1], r2, lsl #8
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r1, r1, #-1073741824
//CHECK-NEXT: 	ldr	r0, [r1], r2, lsl #8
//CHECK-NEXT: 	.bundle_unlock


	ldrne r0, [pc]
//CHECK:    ldrne	r0, [pc]

	ldrne r0, [pc, #4]
//CHECK:    ldrne	r0, [pc, #4]

	ldrne r0, [pc, r2]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	addne	r0, pc, r2
//CHECK-NEXT: 	bicne	r0, r0, #-1073741824
//CHECK-NEXT: 	ldrne	r0, [r0]
//CHECK-NEXT: 	.bundle_unlock

	ldrne r0, [pc, r2, lsl #8]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	addne	r0, pc, r2, lsl #8
//CHECK-NEXT: 	bicne	r0, r0, #-1073741824
//CHECK-NEXT: 	ldrne	r0, [r0]
//CHECK-NEXT: 	.bundle_unlock

	ldrne r0, [sp]
//CHECK:    ldrne	r0, [sp]

	ldrne r0, [sp, #4]
//CHECK:    ldrne	r0, [sp, #4]

	ldrne r0, [sp, #4]!
//CHECK:    ldrne	r0, [sp, #4]!

	ldrne r0, [sp, r2]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	addne	r0, sp, r2
//CHECK-NEXT: 	bicne	r0, r0, #-1073741824
//CHECK-NEXT: 	ldrne	r0, [r0]
//CHECK-NEXT: 	.bundle_unlock

	ldrne r0, [sp, r2]!
//CHECK:    .bundle_lock
//CHECK-NEXT: 	addne	sp, sp, r2
//CHECK-NEXT: 	bicne	sp, sp, #-1073741824
//CHECK-NEXT: 	ldrne	r0, [sp]
//CHECK-NEXT: 	.bundle_unlock

	ldrne r0, [sp], r2
//CHECK:    .bundle_lock
//CHECK-NEXT: 	ldrne	r0, [sp], r2
//CHECK-NEXT: 	bicne	sp, sp, #-1073741824
//CHECK-NEXT: 	.bundle_unlock

	ldrne r0, [sp, r2, lsl #8]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	addne	r0, sp, r2, lsl #8
//CHECK-NEXT: 	bicne	r0, r0, #-1073741824
//CHECK-NEXT: 	ldrne	r0, [r0]
//CHECK-NEXT: 	.bundle_unlock

	ldrne r0, [sp, r2, lsl #8]!
//CHECK:    .bundle_lock
//CHECK-NEXT: 	addne	sp, sp, r2, lsl #8
//CHECK-NEXT: 	bicne	sp, sp, #-1073741824
//CHECK-NEXT: 	ldrne	r0, [sp]
//CHECK-NEXT: 	.bundle_unlock

	ldrne r0, [sp], r2, lsl #8
//CHECK:    .bundle_lock
//CHECK-NEXT: 	ldrne	r0, [sp], r2, lsl #8
//CHECK-NEXT: 	bicne	sp, sp, #-1073741824
//CHECK-NEXT: 	.bundle_unlock

	ldrne r0, [r1]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bicne	r1, r1, #-1073741824
//CHECK-NEXT: 	ldrne	r0, [r1]
//CHECK-NEXT: 	.bundle_unlock

	ldrne r0, [r1, #4]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bicne	r1, r1, #-1073741824
//CHECK-NEXT: 	ldrne	r0, [r1, #4]
//CHECK-NEXT: 	.bundle_unlock

	ldrne r0, [r1, #4]!
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bicne	r1, r1, #-1073741824
//CHECK-NEXT: 	ldrne	r0, [r1, #4]!
//CHECK-NEXT: 	.bundle_unlock

	ldrne r0, [r1, r2]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	addne	r0, r1, r2
//CHECK-NEXT: 	bicne	r0, r0, #-1073741824
//CHECK-NEXT: 	ldrne	r0, [r0]
//CHECK-NEXT: 	.bundle_unlock

	ldrne r0, [r1, r2]!
//CHECK:    .bundle_lock
//CHECK-NEXT: 	addne	r1, r1, r2
//CHECK-NEXT: 	bicne	r1, r1, #-1073741824
//CHECK-NEXT: 	ldrne	r0, [r1]
//CHECK-NEXT: 	.bundle_unlock

	ldrne r0, [r1], r2
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bicne	r1, r1, #-1073741824
//CHECK-NEXT: 	ldrne	r0, [r1], r2
//CHECK-NEXT: 	.bundle_unlock

	ldrne r0, [r1, r2, lsl #8]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	addne	r0, r1, r2, lsl #8
//CHECK-NEXT: 	bicne	r0, r0, #-1073741824
//CHECK-NEXT: 	ldrne	r0, [r0]
//CHECK-NEXT: 	.bundle_unlock

	ldrne r0, [r1, r2, lsl #8]!
//CHECK:    .bundle_lock
//CHECK-NEXT: 	addne	r1, r1, r2, lsl #8
//CHECK-NEXT: 	bicne	r1, r1, #-1073741824
//CHECK-NEXT: 	ldrne	r0, [r1]
//CHECK-NEXT: 	.bundle_unlock

	ldrne r0, [r1], r2, lsl #8
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bicne	r1, r1, #-1073741824
//CHECK-NEXT: 	ldrne	r0, [r1], r2, lsl #8
//CHECK-NEXT: 	.bundle_unlock


// dmb and adr end up getting mayLoad or mayStore flags set, and so end up
// being processed by the expander. Ensure they are not modified.
        dmb sy
//CHECK:  dmb sy
        dmb ish
//CHECK:  dmb ish
// adr encodings are different based on whether the label is before or after the
// instruction
a:      nop
        adr r1, a
// CHECK: adr r1, a
        adr r0, b
// CHECK: adr r0, b
b:      nop
// CHECK: ldr r0, b
        ldr r0, b
