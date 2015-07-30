// RUN: llvm-mc -filetype asm -triple i386-unknown-nacl %s | FileCheck %s

// Test that instructions inside bundle-locked groups are not recursively
// expanded.

        .bundle_lock
        andl	$-32, %eax
        jmpl *%eax
        .bundle_unlock
        inc %ecx
// CHECK: 	.bundle_lock
// CHECK-NEXT:  andl	$-32, %eax
// CHECK-NEXT:  jmpl	*%eax
// CHECK-NEXT:  .bundle_unlock
// Check that there's nothing else before the next unrelated instruction
// CHECK-NEXT:  inc
