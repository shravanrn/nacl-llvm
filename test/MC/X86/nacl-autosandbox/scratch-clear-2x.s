// RUN: llvm-mc -nacl-enable-auto-sandboxing -filetype asm -triple i386-unknown-nacl %s

// Extra .scratch_clear directive. Should not fail.

.scratch %ecx
.scratch_clear
.scratch_clear
