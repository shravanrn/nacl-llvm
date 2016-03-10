; Test the static-linking case.
; RUN: opt < %s -nacl-expand-tls -S | FileCheck %s

; Test the dynamic-linking case.
; RUN: opt < %s -convert-to-pso -pnacl-abi-simplify-postopt \
; RUN:     -verify-pnaclabi-module -verify-pnaclabi-functions -S \
; RUN:     | FileCheck %s -check-prefix=DYNAMIC

target datalayout = "p:32:32:32"


@var = global i32 123

; We put these zero-initialized (a.k.a. BSS) variables first to check that
; the ExpandTls pass correctly places them them after non-BSS variables in
; the TLS template despite their ordering here.
@bss_tvar1 = thread_local global i8 0
@bss_tvar_aligned = thread_local global i32 0, align 64

@tvar1 = thread_local global i16 234
; Test a pointer to check we are getting the right pointer size.
@tvar2 = thread_local global i32* @var
@tvar_aligned = thread_local global i8 99, align 32


; The TLS variables above should be allocated the following offsets:
;
;   @tvar1                         offset = 0   tp_offset=-128
;   [pad 2 bytes to align to 4]
;   @tvar2                         offset = 4   tp_offset=-124
;   [pad 24 bytes to align to 32]
;   @tvar_aligned                  offset = 32  tp_offset=-96
;   @bss_tvar1                     offset = 33  tp_offset=-95
;   [pad 30 bytes to align to 64]
;   @bss_tvar_aligned              offset = 64  tp_offset=-64
;
; where "offset" is the variable's offset from the start of the TLS
; template, while "tp_offset" is the variable's offset from the thread
; pointer.
;
; Our use of x86-style layout gives us:
;   tp_offset = offset - 128
; where 128 is the total size of the TLS template.


; CHECK: %tls_init_template = type <{ i16, [2 x i8], i32*, [24 x i8], i8 }>


; CHECK: @__tls_template_start = internal constant %tls_init_template <{ i16 234, [2 x i8] zeroinitializer, i32* @var, [24 x i8] zeroinitializer, i8 99 }>

; CHECK: @__tls_template_alignment = internal constant i32 64

; DYNAMIC: @__tls_template = internal constant <{ [4 x i8], i32, [25 x i8] }>

; DYNAMIC: @__tls_getter_closure = internal global [8 x i8] zeroinitializer


; Test for use of correct offsets.

define i16* @get_tvar1() {
  ret i16* @tvar1
}
; CHECK: define i16* @get_tvar1()
; CHECK: %tvar1.i8 = getelementptr i8, i8* %thread_ptr, i32 -128
; DYNAMIC: define internal i32 @get_tvar1()
; DYNAMIC: %tvar1 = add i32 %tls_base, 0


define i32** @get_tvar2() {
  ret i32** @tvar2
}
; CHECK: define i32** @get_tvar2()
; CHECK: %tvar2.i8 = getelementptr i8, i8* %thread_ptr, i32 -124
; DYNAMIC: define internal i32 @get_tvar2()
; DYNAMIC: %tvar2 = add i32 %tls_base, 4


define i8* @get_tvar_aligned() {
  ret i8* @tvar_aligned
}
; CHECK: define i8* @get_tvar_aligned()
; CHECK: %tvar_aligned.i8 = getelementptr i8, i8* %thread_ptr, i32 -96
; DYNAMIC: define internal i32 @get_tvar_aligned()
; DYNAMIC: %tvar_aligned = add i32 %tls_base, 32


define i8* @get_bss_tvar1() {
  ret i8* @bss_tvar1
}
; CHECK: define i8* @get_bss_tvar1()
; CHECK: %bss_tvar1.i8 = getelementptr i8, i8* %thread_ptr, i32 -95
; DYNAMIC: define internal i32 @get_bss_tvar1()
; DYNAMIC: %bss_tvar1 = add i32 %tls_base, 33


define i32* @get_bss_tvar_aligned() {
  ret i32* @bss_tvar_aligned
}
; CHECK: define i32* @get_bss_tvar_aligned()
; CHECK: %bss_tvar_aligned.i8 = getelementptr i8, i8* %thread_ptr, i32 -64
; DYNAMIC: define internal i32 @get_bss_tvar_aligned()
; DYNAMIC: %bss_tvar_aligned = add i32 %tls_base, 64


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
; CHECK: ret i8* getelementptr (i8, i8* bitcast (%tls_init_template* @__tls_template_start to i8*), i32 33)

define i8* @get_tls_template_end() {
  ret i8* @__tls_template_end
}
; CHECK: define i8* @get_tls_template_end()
; CHECK: ret i8* getelementptr (i8, i8* bitcast (%tls_init_template* @__tls_template_start to i8*), i32 128)
