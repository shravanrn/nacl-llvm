; RUN: not opt -nacl-expand-ints %s

; This checks that -nacl-expand-ints can't rewrite function signatures with
; large integers in the return position.

define i65 @largeintegerret() {
  ret i65 0
}
