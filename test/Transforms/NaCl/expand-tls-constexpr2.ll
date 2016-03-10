; Test the static-linking case.
; RUN: opt < %s -nacl-expand-tls -S | FileCheck %s

; Test the dynamic-linking case.
; RUN: opt < %s -convert-to-pso -S | FileCheck %s -check-prefix=DYNAMIC

target datalayout = "p:32:32:32"


@tvar = thread_local global i32 0

define i32 @get_tvar() {
  ret i32 ptrtoint (i32* @tvar to i32)
}
; CHECK: define i32 @get_tvar()
; CHECK-NEXT: %thread_ptr = call i8* @llvm.nacl.read.tp()
; CHECK-NEXT: %tvar.i8 = getelementptr i8, i8* %thread_ptr, i32 -4
; CHECK-NEXT: %tvar = bitcast i8* %tvar.i8 to i32*
; CHECK-NEXT: %expanded = ptrtoint i32* %tvar to i32
; CHECK: ret i32 %expanded
; DYNAMIC: define internal i32 @get_tvar()
; DYNAMIC: %tvar = add i32 %tls_base, 0
; DYNAMIC-NEXT: %tvar.ptr = inttoptr i32 %tvar to i32*
; DYNAMIC-NEXT: %expanded = ptrtoint i32* %tvar.ptr to i32
; DYNAMIC-NEXT: ret i32 %expanded
