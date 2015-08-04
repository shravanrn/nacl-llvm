; RUN: not opt -nacl-expand-ints %s

; This checks that -nacl-expand-ints can't rewrite function signatures with
; large integers as an argument.

define void @largeintegerarg(i65) {
  ret void
}
