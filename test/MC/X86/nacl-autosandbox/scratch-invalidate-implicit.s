// RUN: not llvm-mc -nacl-enable-auto-sandboxing -filetype asm -triple x86_64-unknown-nacl %s 2>&1 | FileCheck %s

.scratch %rdx
        mov (%rax, %rbx), %rax
        // div overwrites %edx implicitly.
        div %ebx
        ret
// Checking both stdout and stderr is unreliable because of the ordering, so
// check that the error message refers to the ret and not the mov       
// CHECK: No scratch registers
// CHECK-NOT: mov
// CHECK: ret
