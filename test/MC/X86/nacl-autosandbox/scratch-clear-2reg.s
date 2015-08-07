// RUN: not llvm-mc -nacl-enable-auto-sandboxing -filetype asm -triple i386-unknown-nacl %s 2>&1 | FileCheck %s

// Tests a more complicated sequence of .scratch/.clear_scratch, and checks that
// clear_scratch clears both registers.

.scratch %ecx
.scratch_clear
.scratch %ecx
.scratch %edx
.scratch_clear
        ret
 // CHECK: No scratch registers
