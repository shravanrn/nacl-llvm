// RUN: llvm-mc -nacl-enable-auto-sandboxing -filetype asm -triple i386-unknown-nacl %s

// Tests a more complicated sequence of .scratch/.unscratch
// should succeed

.scratch %ecx
.unscratch
.scratch %ecx
.scratch %edx
.unscratch
.unscratch
