// RUN: llvm-mc -nacl-enable-auto-sandboxing -filetype asm -triple x86_64-unknown-nacl %s | FileCheck %s
.scratch %r12
.scratch %r11

        mov (%rax, %rcx), %r11
        ret
// Check that %r12 is used and not %r11
// CHECK: jmpq *%r12
