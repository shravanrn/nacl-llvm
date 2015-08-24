// RUN: llvm-mc -nacl-enable-auto-sandboxing -filetype asm -triple armv7-unknown-nacl %s 2>/dev/null | FileCheck %s
.scratch r11


	stmia r0, { r1, r2 }
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	stm	r0, {r1, r2}
//CHECK-NEXT: 	.bundle_unlock

	stmiane r0, { r1, r2 }
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bicne	r0, r0, #-1073741824
//CHECK-NEXT: 	stmne	r0, {r1, r2}
//CHECK-NEXT: 	.bundle_unlock

	stmdb r0, { r1, r2 }
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	stmdb	r0, {r1, r2}
//CHECK-NEXT: 	.bundle_unlock

	stmdbne r0, { r1, r2 }
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bicne	r0, r0, #-1073741824
//CHECK-NEXT: 	stmdbne	r0, {r1, r2}
//CHECK-NEXT: 	.bundle_unlock


	str r0, [pc]
//CHECK:    str	r0, [pc]

	str r0, [pc, #4]
//CHECK:    str	r0, [pc, #4]

	str r0, [pc, r2]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	add	r11, pc, r2
//CHECK-NEXT: 	bic	r11, r11, #-1073741824
//CHECK-NEXT: 	str	r0, [r11]
//CHECK-NEXT: 	.bundle_unlock

	str r0, [pc, r2, lsl #8]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	add	r11, pc, r2, lsl #8
//CHECK-NEXT: 	bic	r11, r11, #-1073741824
//CHECK-NEXT: 	str	r0, [r11]
//CHECK-NEXT: 	.bundle_unlock

	str r0, [sp]
//CHECK:    str	r0, [sp]

	str r0, [sp, #4]
//CHECK:    str	r0, [sp, #4]

	str r0, [sp, #4]!
//CHECK:    str	r0, [sp, #4]!

	str r0, [sp, r2]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	add	r11, sp, r2
//CHECK-NEXT: 	bic	r11, r11, #-1073741824
//CHECK-NEXT: 	str	r0, [r11]
//CHECK-NEXT: 	.bundle_unlock

	str r0, [sp, r2]!
//CHECK:    .bundle_lock
//CHECK-NEXT: 	add	sp, sp, r2
//CHECK-NEXT: 	bic	sp, sp, #-1073741824
//CHECK-NEXT: 	str	r0, [sp]
//CHECK-NEXT: 	.bundle_unlock

	str r0, [sp], r2
//CHECK:    .bundle_lock
//CHECK-NEXT: 	str	r0, [sp], r2
//CHECK-NEXT: 	bic	sp, sp, #-1073741824
//CHECK-NEXT: 	.bundle_unlock

	str r0, [sp, r2, lsl #8]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	add	r11, sp, r2, lsl #8
//CHECK-NEXT: 	bic	r11, r11, #-1073741824
//CHECK-NEXT: 	str	r0, [r11]
//CHECK-NEXT: 	.bundle_unlock

	str r0, [sp, r2, lsl #8]!
//CHECK:    .bundle_lock
//CHECK-NEXT: 	add	sp, sp, r2, lsl #8
//CHECK-NEXT: 	bic	sp, sp, #-1073741824
//CHECK-NEXT: 	str	r0, [sp]
//CHECK-NEXT: 	.bundle_unlock

	str r0, [sp], r2, lsl #8
//CHECK:    .bundle_lock
//CHECK-NEXT: 	str	r0, [sp], r2, lsl #8
//CHECK-NEXT: 	bic	sp, sp, #-1073741824
//CHECK-NEXT: 	.bundle_unlock

	str r0, [r1]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r1, r1, #-1073741824
//CHECK-NEXT: 	str	r0, [r1]
//CHECK-NEXT: 	.bundle_unlock

	str r0, [r1, #4]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r1, r1, #-1073741824
//CHECK-NEXT: 	str	r0, [r1, #4]
//CHECK-NEXT: 	.bundle_unlock

	str r0, [r1, #4]!
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r1, r1, #-1073741824
//CHECK-NEXT: 	str	r0, [r1, #4]!
//CHECK-NEXT: 	.bundle_unlock

	str r0, [r1, r2]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	add	r11, r1, r2
//CHECK-NEXT: 	bic	r11, r11, #-1073741824
//CHECK-NEXT: 	str	r0, [r11]
//CHECK-NEXT: 	.bundle_unlock

	str r0, [r1, r2]!
//CHECK:    .bundle_lock
//CHECK-NEXT: 	add	r1, r1, r2
//CHECK-NEXT: 	bic	r1, r1, #-1073741824
//CHECK-NEXT: 	str	r0, [r1]
//CHECK-NEXT: 	.bundle_unlock

	str r0, [r1], r2
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r1, r1, #-1073741824
//CHECK-NEXT: 	str	r0, [r1], r2
//CHECK-NEXT: 	.bundle_unlock

	str r0, [r1, r2, lsl #8]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	add	r11, r1, r2, lsl #8
//CHECK-NEXT: 	bic	r11, r11, #-1073741824
//CHECK-NEXT: 	str	r0, [r11]
//CHECK-NEXT: 	.bundle_unlock

	str r0, [r1, r2, lsl #8]!
//CHECK:    .bundle_lock
//CHECK-NEXT: 	add	r1, r1, r2, lsl #8
//CHECK-NEXT: 	bic	r1, r1, #-1073741824
//CHECK-NEXT: 	str	r0, [r1]
//CHECK-NEXT: 	.bundle_unlock

	str r0, [r1], r2, lsl #8
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r1, r1, #-1073741824
//CHECK-NEXT: 	str	r0, [r1], r2, lsl #8
//CHECK-NEXT: 	.bundle_unlock


	strne r0, [pc]
//CHECK:    strne	r0, [pc]

	strne r0, [pc, #4]
//CHECK:    strne	r0, [pc, #4]

	strne r0, [pc, r2]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	addne	r11, pc, r2
//CHECK-NEXT: 	bicne	r11, r11, #-1073741824
//CHECK-NEXT: 	strne	r0, [r11]
//CHECK-NEXT: 	.bundle_unlock

	strne r0, [pc, r2, lsl #8]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	addne	r11, pc, r2, lsl #8
//CHECK-NEXT: 	bicne	r11, r11, #-1073741824
//CHECK-NEXT: 	strne	r0, [r11]
//CHECK-NEXT: 	.bundle_unlock

	strne r0, [sp]
//CHECK:    strne	r0, [sp]

	strne r0, [sp, #4]
//CHECK:    strne	r0, [sp, #4]

	strne r0, [sp, #4]!
//CHECK:    strne	r0, [sp, #4]!

	strne r0, [sp, r2]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	addne	r11, sp, r2
//CHECK-NEXT: 	bicne	r11, r11, #-1073741824
//CHECK-NEXT: 	strne	r0, [r11]
//CHECK-NEXT: 	.bundle_unlock

	strne r0, [sp, r2]!
//CHECK:    .bundle_lock
//CHECK-NEXT: 	addne	sp, sp, r2
//CHECK-NEXT: 	bicne	sp, sp, #-1073741824
//CHECK-NEXT: 	strne	r0, [sp]
//CHECK-NEXT: 	.bundle_unlock

	strne r0, [sp], r2
//CHECK:    .bundle_lock
//CHECK-NEXT: 	strne	r0, [sp], r2
//CHECK-NEXT: 	bicne	sp, sp, #-1073741824
//CHECK-NEXT: 	.bundle_unlock

	strne r0, [sp, r2, lsl #8]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	addne	r11, sp, r2, lsl #8
//CHECK-NEXT: 	bicne	r11, r11, #-1073741824
//CHECK-NEXT: 	strne	r0, [r11]
//CHECK-NEXT: 	.bundle_unlock

	strne r0, [sp, r2, lsl #8]!
//CHECK:    .bundle_lock
//CHECK-NEXT: 	addne	sp, sp, r2, lsl #8
//CHECK-NEXT: 	bicne	sp, sp, #-1073741824
//CHECK-NEXT: 	strne	r0, [sp]
//CHECK-NEXT: 	.bundle_unlock

	strne r0, [sp], r2, lsl #8
//CHECK:    .bundle_lock
//CHECK-NEXT: 	strne	r0, [sp], r2, lsl #8
//CHECK-NEXT: 	bicne	sp, sp, #-1073741824
//CHECK-NEXT: 	.bundle_unlock

	strne r0, [r1]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bicne	r1, r1, #-1073741824
//CHECK-NEXT: 	strne	r0, [r1]
//CHECK-NEXT: 	.bundle_unlock

	strne r0, [r1, #4]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bicne	r1, r1, #-1073741824
//CHECK-NEXT: 	strne	r0, [r1, #4]
//CHECK-NEXT: 	.bundle_unlock

	strne r0, [r1, #4]!
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bicne	r1, r1, #-1073741824
//CHECK-NEXT: 	strne	r0, [r1, #4]!
//CHECK-NEXT: 	.bundle_unlock

	strne r0, [r1, r2]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	addne	r11, r1, r2
//CHECK-NEXT: 	bicne	r11, r11, #-1073741824
//CHECK-NEXT: 	strne	r0, [r11]
//CHECK-NEXT: 	.bundle_unlock

	strne r0, [r1, r2]!
//CHECK:    .bundle_lock
//CHECK-NEXT: 	addne	r1, r1, r2
//CHECK-NEXT: 	bicne	r1, r1, #-1073741824
//CHECK-NEXT: 	strne	r0, [r1]
//CHECK-NEXT: 	.bundle_unlock

	strne r0, [r1], r2
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bicne	r1, r1, #-1073741824
//CHECK-NEXT: 	strne	r0, [r1], r2
//CHECK-NEXT: 	.bundle_unlock

	strne r0, [r1, r2, lsl #8]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	addne	r11, r1, r2, lsl #8
//CHECK-NEXT: 	bicne	r11, r11, #-1073741824
//CHECK-NEXT: 	strne	r0, [r11]
//CHECK-NEXT: 	.bundle_unlock

	strne r0, [r1, r2, lsl #8]!
//CHECK:    .bundle_lock
//CHECK-NEXT: 	addne	r1, r1, r2, lsl #8
//CHECK-NEXT: 	bicne	r1, r1, #-1073741824
//CHECK-NEXT: 	strne	r0, [r1]
//CHECK-NEXT: 	.bundle_unlock

	strne r0, [r1], r2, lsl #8
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bicne	r1, r1, #-1073741824
//CHECK-NEXT: 	strne	r0, [r1], r2, lsl #8
//CHECK-NEXT: 	.bundle_unlock

