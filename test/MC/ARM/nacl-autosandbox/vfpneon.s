// RUN: llvm-mc -nacl-enable-auto-sandboxing -filetype asm -triple armv7-unknown-nacl %s 2>/dev/null | FileCheck %s


	vld1.8 { d0 }, [sp]
//CHECK:    vld1.8	{d0}, [sp]

	vld1.8 { d0 }, [r0]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	vld1.8	{d0}, [r0]
//CHECK-NEXT: 	.bundle_unlock


	vld4.8 { d0, d1, d2, d3}, [r0]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	vld4.8	{d0, d1, d2, d3}, [r0]
//CHECK-NEXT: 	.bundle_unlock

	vld4.8 { d0, d1, d2, d3}, [r0]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	vld4.8	{d0, d1, d2, d3}, [r0]
//CHECK-NEXT: 	.bundle_unlock


	vld4.8 { d0, d1, d2, d3}, [r0], r1
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	vld4.8	{d0, d1, d2, d3}, [r0], r1
//CHECK-NEXT: 	.bundle_unlock

	vld4.8 { d0, d1, d2, d3}, [r0], r1
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	vld4.8	{d0, d1, d2, d3}, [r0], r1
//CHECK-NEXT: 	.bundle_unlock


	vld4ne.8 { d0, d1, d2, d3}, [r0]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bicne	r0, r0, #-1073741824
//CHECK-NEXT: 	vld4ne.8	{d0, d1, d2, d3}, [r0]
//CHECK-NEXT: 	.bundle_unlock

	vld4ne.8 { d0, d1, d2, d3}, [r0]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bicne	r0, r0, #-1073741824
//CHECK-NEXT: 	vld4ne.8	{d0, d1, d2, d3}, [r0]
//CHECK-NEXT: 	.bundle_unlock


	vld4ne.8 { d0, d1, d2, d3}, [r0]!
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bicne	r0, r0, #-1073741824
//CHECK-NEXT: 	vld4ne.8	{d0, d1, d2, d3}, [r0]!
//CHECK-NEXT: 	.bundle_unlock

	vld4ne.8 { d0, d1, d2, d3}, [r0]!
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bicne	r0, r0, #-1073741824
//CHECK-NEXT: 	vld4ne.8	{d0, d1, d2, d3}, [r0]!
//CHECK-NEXT: 	.bundle_unlock


	vld4ne.8 { d0, d1, d2, d3}, [r0], r1
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bicne	r0, r0, #-1073741824
//CHECK-NEXT: 	vld4ne.8	{d0, d1, d2, d3}, [r0], r1
//CHECK-NEXT: 	.bundle_unlock

	vld4ne.8 { d0, d1, d2, d3}, [r0], r1
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bicne	r0, r0, #-1073741824
//CHECK-NEXT: 	vld4ne.8	{d0, d1, d2, d3}, [r0], r1
//CHECK-NEXT: 	.bundle_unlock

	

	vst1.8 { d0 }, [sp]
//CHECK:    vst1.8	{d0}, [sp]

	vst1.8 { d0 }, [r0]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	vst1.8	{d0}, [r0]
//CHECK-NEXT: 	.bundle_unlock


	vst4.8 { d0, d1, d2, d3}, [r0]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	vst4.8	{d0, d1, d2, d3}, [r0]
//CHECK-NEXT: 	.bundle_unlock

	vst4.8 { d0, d1, d2, d3}, [r0]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	vst4.8	{d0, d1, d2, d3}, [r0]
//CHECK-NEXT: 	.bundle_unlock


	vst4ne.8 { d0, d1, d2, d3}, [r0]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bicne	r0, r0, #-1073741824
//CHECK-NEXT: 	vst4ne.8	{d0, d1, d2, d3}, [r0]
//CHECK-NEXT: 	.bundle_unlock

	vst4ne.8 { d0, d1, d2, d3}, [r0]
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bicne	r0, r0, #-1073741824
//CHECK-NEXT: 	vst4ne.8	{d0, d1, d2, d3}, [r0]
//CHECK-NEXT: 	.bundle_unlock


	vst4ne.8 { d0, d1, d2, d3}, [r0]!
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bicne	r0, r0, #-1073741824
//CHECK-NEXT: 	vst4ne.8	{d0, d1, d2, d3}, [r0]!
//CHECK-NEXT: 	.bundle_unlock

	vst4ne.8 { d0, d1, d2, d3}, [r0]!
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bicne	r0, r0, #-1073741824
//CHECK-NEXT: 	vst4ne.8	{d0, d1, d2, d3}, [r0]!
//CHECK-NEXT: 	.bundle_unlock


	vst4.8 { d0, d1, d2, d3}, [r0], r1
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	vst4.8	{d0, d1, d2, d3}, [r0], r1
//CHECK-NEXT: 	.bundle_unlock

	vst4.8 { d0, d1, d2, d3}, [r0], r1
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	vst4.8	{d0, d1, d2, d3}, [r0], r1
//CHECK-NEXT: 	.bundle_unlock


	vst4ne.8 { d0, d1, d2, d3}, [sp]
//CHECK:    vst4ne.8	{d0, d1, d2, d3}, [sp]

	vst4ne.8 { d0, d1, d2, d3}, [sp]
//CHECK:    vst4ne.8	{d0, d1, d2, d3}, [sp]


	vst4ne.8 { d0, d1, d2, d3}, [r0], r1
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bicne	r0, r0, #-1073741824
//CHECK-NEXT: 	vst4ne.8	{d0, d1, d2, d3}, [r0], r1
//CHECK-NEXT: 	.bundle_unlock

	vst4ne.8 { d0, d1, d2, d3}, [r0], r1
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bicne	r0, r0, #-1073741824
//CHECK-NEXT: 	vst4ne.8	{d0, d1, d2, d3}, [r0], r1
//CHECK-NEXT: 	.bundle_unlock

	vst4.8 { d0, d1, d2, d3}, [sp]!
//CHECK:    .bundle_lock
//CHECK-NEXT: 	vst4.8	{d0, d1, d2, d3}, [sp]!
//CHECK-NEXT: 	bic	sp, sp, #-1073741824
//CHECK-NEXT: 	.bundle_unlock

	vst4.8 { d0, d1, d2, d3}, [sp], r1
//CHECK:    .bundle_lock
//CHECK-NEXT: 	vst4.8	{d0, d1, d2, d3}, [sp], r1
//CHECK-NEXT: 	bic	sp, sp, #-1073741824
//CHECK-NEXT: 	.bundle_unlock
