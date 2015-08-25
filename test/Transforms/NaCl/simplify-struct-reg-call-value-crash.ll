; RUN: opt < %s -simplify-struct-reg-signatures -S
target datalayout = "e-p:32:32-i64:64-n32"
target triple = "le32-unknown-nacl"

%0 = type { %1, %0*, i32 }
%1 = type { [128 x i64] }
%2 = type { %3, i32, i32 }
%3 = type { %4, %5 }
%4 = type { i8* }
%5 = type {}

@__pnacl_eh_stack = thread_local global %0* null, align 4
@llvm.global_ctors = appending global [1 x { i32, void ()*, i8* }] [{ i32, void ()*, i8* } { i32 65535, void ()* null, i8* null }]

; Function Attrs: uwtable
define void @_ZN3ffi5c_str13CString.Clone5clone20h1be2cef1c3cb804cyveE() unnamed_addr #0 {
  call fastcc void null(%2* noalias dereferenceable(12) undef, i32 undef)
  %1 = call fastcc { i8*, i32 } null(%2* noalias nocapture dereferenceable(12) undef)
  ret void
}

attributes #0 = { uwtable }
