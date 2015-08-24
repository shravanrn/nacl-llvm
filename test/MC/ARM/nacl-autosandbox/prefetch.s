// RUN: llvm-mc -nacl-enable-auto-sandboxing -filetype asm -triple armv7-unknown-nacl %s 2>/dev/null | FileCheck %s
.scratch r11

	pld [pc]
//CHECK:    pld	[pc]

	pld [pc, #4]
//CHECK:    pld	[pc, #4]

	pld [pc, r0]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	add	r11, pc, r0
//CHECK-NEXT: 	bic	r11, r11, #-1073741824
//CHECK-NEXT: 	pld	[r11]
//CHECK-NEXT: 	.bundle_unlock

	pld [pc, r0, lsl #12]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	add	r11, pc, r0, lsl #12
//CHECK-NEXT: 	bic	r11, r11, #-1073741824
//CHECK-NEXT: 	pld	[r11]
//CHECK-NEXT: 	.bundle_unlock
	

	pld [sp]
//CHECK:    pld	[sp]

	pld [sp, #4]
//CHECK:    pld	[sp, #4]

	pld [sp, r0]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	add	r11, sp, r0
//CHECK-NEXT: 	bic	r11, r11, #-1073741824
//CHECK-NEXT: 	pld	[r11]
//CHECK-NEXT: 	.bundle_unlock

	pld [sp, r0, lsl #12]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	add	r11, sp, r0, lsl #12
//CHECK-NEXT: 	bic	r11, r11, #-1073741824
//CHECK-NEXT: 	pld	[r11]
//CHECK-NEXT: 	.bundle_unlock


	pld [r0]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	pld	[r0]
//CHECK-NEXT: 	.bundle_unlock

	pld [r0, #4]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	pld	[r0, #4]
//CHECK-NEXT: 	.bundle_unlock

	pld [r0, r1]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	add	r11, r0, r1
//CHECK-NEXT: 	bic	r11, r11, #-1073741824
//CHECK-NEXT: 	pld	[r11]
//CHECK-NEXT: 	.bundle_unlock

	pld [r0, r1, lsl #12]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	add	r11, r0, r1, lsl #12
//CHECK-NEXT: 	bic	r11, r11, #-1073741824
//CHECK-NEXT: 	pld	[r11]
//CHECK-NEXT: 	.bundle_unlock
