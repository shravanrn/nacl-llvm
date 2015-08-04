; RUN: opt -rewrite-llvm-intrinsic-calls -S %s | FileCheck %s

target datalayout = "p:32:32:32"

declare void @llvm.debugtrap()

define void @f() {
  call void @llvm.debugtrap()
; CHECK: @llvm.trap
; CHECK-NOT: @llvm.debugtrap
  ret void
}
