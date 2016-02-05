; RUN: llvm-as < %s | pnacl-freeze | pnacl-thaw | llvm-dis - | FileCheck %s
; RUN: llvm-as < %s | pnacl-freeze | pnacl-addnames | pnacl-thaw | llvm-dis - \
; RUN:              | FileCheck %s -check-prefix=NAME

; Test that we generate names values for unnamed global variables and functions.

@0 = internal global [7 x i8] c"abcdefg"
; CHECK: @0 = internal global [7 x i8] c"abcdefg"
; NAME: @Global1 = internal global [7 x i8] c"abcdefg"

@named_global = internal global i32 ptrtoint ([7 x i8]* @0 to i32)
; CHECK: @named_global = internal global i32 ptrtoint ([7 x i8]* @0 to i32)
; NAME: @named_global = internal global i32 ptrtoint ([7 x i8]* @Global1 to i32)

define void @1() {
; CHECK: define void @1() {
; NAME: define void @Function0() {
  ret void
}

define i32 @named_function() {
; CHECK: define i32 @named_function() {
; NAME: define i32 @named_function() {
  ret i32 10
}
