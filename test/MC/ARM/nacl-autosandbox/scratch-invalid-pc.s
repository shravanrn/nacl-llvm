// RUN: not llvm-mc -nacl-enable-auto-sandboxing -filetype asm -triple armv7-unknown-nacl %s 2>&1 | FileCheck %s

.scratch pc
// CHECK: Register can't be used as a scratch register
