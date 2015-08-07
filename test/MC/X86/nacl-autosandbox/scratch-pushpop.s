// RUN: llvm-mc -nacl-enable-auto-sandboxing -filetype asm -triple i386-unknown-nacl %s

// Tests a basic .scratch and .unscratch sequence, should succeed

.scratch %ecx
.unscratch
