// RUN: llvm-mc -nacl-enable-auto-sandboxing -filetype asm -triple armv7-unknown-nacl %s 2>/dev/null | FileCheck %s
.scratch r11


	vstmia r0, { d1, d2 }
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	vstmia	r0, {d1, d2}
//CHECK-NEXT: 	.bundle_unlock

	vstmiane r0, { d1, d2 }
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bicne	r0, r0, #-1073741824
//CHECK-NEXT: 	vstmiane	r0, {d1, d2}
//CHECK-NEXT: 	.bundle_unlock

	vstmdb r0!, { d1, d2 }
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	vstmdb	r0!, {d1, d2}
//CHECK-NEXT: 	.bundle_unlock

	vstmdbne r0!, { d1, d2 }
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bicne	r0, r0, #-1073741824
//CHECK-NEXT: 	vstmdbne	r0!, {d1, d2}
//CHECK-NEXT: 	.bundle_unlock

	vstmia r0, { s1, s2 }
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	vstmia	r0, {s1, s2}
//CHECK-NEXT: 	.bundle_unlock

        vstmia r0, { q1, q2 }
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	vstmia	r0, {d2, d3, d4, d5}
//CHECK-NEXT: 	.bundle_unlock

        vldmia r0, { d1, d2 }
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	vldmia	r0, {d1, d2}
//CHECK-NEXT: 	.bundle_unlock

        vldmia r0, { s1, s2 }
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	vldmia	r0, {s1, s2}
//CHECK-NEXT: 	.bundle_unlock

        vldmia r0!, { d1, d2 }
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	vldmia	r0!, {d1, d2}
//CHECK-NEXT: 	.bundle_unlock
        
        vldmia r0!, { s1, s2 }
//CHECK:    .bundle_lock
//CHECK-NEXT: 	bic	r0, r0, #-1073741824
//CHECK-NEXT: 	vldmia	r0!, {s1, s2}
//CHECK-NEXT: 	.bundle_unlock
