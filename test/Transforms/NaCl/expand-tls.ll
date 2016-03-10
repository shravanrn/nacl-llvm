; Test the static-linking case.
; RUN: opt < %s -nacl-expand-tls -S | FileCheck %s

; Test the dynamic-linking case.
; RUN: opt < %s -convert-to-pso -pnacl-abi-simplify-postopt \
; RUN:     -verify-pnaclabi-module -verify-pnaclabi-functions -S \
; RUN:     | FileCheck %s -check-prefix=DYNAMIC

; All thread-local variables should be removed
; RUN: opt < %s -nacl-expand-tls -S | FileCheck %s -check-prefix=NO_TLS

; NO_TLS-NOT: thread_local

target datalayout = "p:32:32:32"

@tvar1 = thread_local global i64 123
@tvar2 = thread_local global i32 456


; CHECK: %tls_init_template = type <{ i64, i32 }>


; CHECK: @__tls_template_start = internal constant %tls_init_template <{ i64 123, i32 456 }>

; CHECK: @__tls_template_alignment = internal constant i32 8

; DYNAMIC: @__tls_template = internal constant [12 x i8]

; DYNAMIC: @__tls_getter_closure = internal global [8 x i8] zeroinitializer


define i64* @get_tvar1() {
  ret i64* @tvar1
}
; CHECK: define i64* @get_tvar1()
; CHECK-NEXT: %thread_ptr = call i8* @llvm.nacl.read.tp()
; CHECK-NEXT: %tvar1.i8 = getelementptr i8, i8* %thread_ptr, i32 -16
; CHECK-NEXT: %tvar1 = bitcast i8* %tvar1.i8 to i64*
; CHECK-NEXT: ret i64* %tvar1
; DYNAMIC: define internal i32 @get_tvar1()
; DYNAMIC-NEXT: %__tls_getter_closure.bc = bitcast {{.*}} @__tls_getter_closure
; DYNAMIC-NEXT: %tls_getter_func = load i32, i32* %__tls_getter_closure.bc
; DYNAMIC-NEXT: %tls_getter_func.asptr = inttoptr i32 %tls_getter_func to i32 (i32)*
; DYNAMIC-NEXT: %expanded1 = ptrtoint [8 x i8]* @__tls_getter_closure to i32
; DYNAMIC-NEXT: %tls_base = call i32 %tls_getter_func.asptr(i32 %expanded1)
; DYNAMIC-NEXT: %tvar1 = add i32 %tls_base, 0
; DYNAMIC-NEXT: ret i32 %tvar1


define i32* @get_tvar2() {
  ret i32* @tvar2
}
; CHECK: define i32* @get_tvar2()
; CHECK-NEXT: %thread_ptr = call i8* @llvm.nacl.read.tp()
; CHECK-NEXT: %tvar2.i8 = getelementptr i8, i8* %thread_ptr, i32 -8
; CHECK-NEXT: %tvar2 = bitcast i8* %tvar2.i8 to i32*
; CHECK-NEXT: ret i32* %tvar2
; DYNAMIC: define internal i32 @get_tvar2()
; DYNAMIC-NEXT: %__tls_getter_closure.bc = bitcast {{.*}} @__tls_getter_closure
; DYNAMIC-NEXT: %tls_getter_func = load i32, i32* %__tls_getter_closure.bc
; DYNAMIC-NEXT: %tls_getter_func.asptr = inttoptr i32 %tls_getter_func to i32 (i32)*
; DYNAMIC-NEXT: %expanded1 = ptrtoint [8 x i8]* @__tls_getter_closure to i32
; DYNAMIC-NEXT: %tls_base = call i32 %tls_getter_func.asptr(i32 %expanded1)
; DYNAMIC-NEXT: %tvar2 = add i32 %tls_base, 8
; DYNAMIC-NEXT: ret i32 %tvar2


; Check that we define global variables for TLS templates

@__tls_template_start = external global i8
@__tls_template_tdata_end = external global i8
@__tls_template_end = external global i8

define i8* @get_tls_template_start() {
  ret i8* @__tls_template_start
}
; CHECK: define i8* @get_tls_template_start()
; CHECK: ret i8* bitcast (%tls_init_template* @__tls_template_start to i8*)

define i8* @get_tls_template_tdata_end() {
  ret i8* @__tls_template_tdata_end
}
; CHECK: define i8* @get_tls_template_tdata_end()
; CHECK: ret i8* getelementptr (i8, i8* bitcast (%tls_init_template* @__tls_template_start to i8*), i32 12)

define i8* @get_tls_template_end() {
  ret i8* @__tls_template_end
}
; CHECK: define i8* @get_tls_template_end()
; CHECK: ret i8* getelementptr (i8, i8* bitcast (%tls_init_template* @__tls_template_start to i8*), i32 16)


; Check that we define the TLS layout functions

declare i32 @__nacl_tp_tls_offset(i32)
declare i32 @__nacl_tp_tdb_offset(i32)

define i32 @test_get_tp_tls_offset(i32 %tls_size) {
  %offset = call i32 @__nacl_tp_tls_offset(i32 %tls_size)
  ret i32 %offset
}
; Uses of the intrinsic are replaced with uses of a regular function.
; CHECK: define i32 @test_get_tp_tls_offset
; CHECK: call i32 @nacl_tp_tls_offset
; NO_TLS-NOT: __nacl_tp_tls_offset

define i32 @test_get_tp_tdb_offset(i32 %tdb_size) {
  %offset = call i32 @__nacl_tp_tdb_offset(i32 %tdb_size)
  ret i32 %offset
}
; Uses of the intrinsic are replaced with uses of a regular function.
; CHECK: define i32 @test_get_tp_tdb_offset
; CHECK: call i32 @nacl_tp_tdb_offset
; NO_TLS-NOT: __nacl_tp_tdb_offset
