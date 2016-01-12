; This tests that the output of "-convert-to-pso" passes PNaCl's ABI verifier.
; RUN: opt < %s -convert-to-pso -pnacl-abi-simplify-postopt \
; RUN:     -verify-pnaclabi-module -verify-pnaclabi-functions -S | FileCheck %s

; CHECK: @__pnacl_pso_root = constant

target datalayout = "p:32:32:32"


; Test exporting variables.
@var1 = global i32 123
@var2 = global i32 456

; Test exporting multiple functions.
define i32 @exported_foo() {
  ret i32 1234
}

define i32 @exported_bar() {
  ret i32 5678
}


; Test references to intrinsics.
declare i8* @llvm.nacl.read.tp()

define i8* @my_read_tp() {
  %thread_pointer = call i8* @llvm.nacl.read.tp()
  ret i8* %thread_pointer
}
