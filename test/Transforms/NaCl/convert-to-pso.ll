; This tests that the output of "-convert-to-pso" passes PNaCl's ABI verifier.
; RUN: opt < %s -convert-to-pso -convert-to-pso-deps=libfoo.so,libbar.so \
; RUN:     -pnacl-abi-simplify-postopt -verify-pnaclabi-module \
; RUN:     -verify-pnaclabi-functions -S | FileCheck %s

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


; Test exporting aliases
@var1_alias = alias i32* @var1
@exported_foo_alias = alias i32 ()* @exported_foo


; Test references to intrinsics.
declare i8* @llvm.nacl.read.tp()

define i8* @my_read_tp() {
  %thread_pointer = call i8* @llvm.nacl.read.tp()
  ret i8* %thread_pointer
}


; Test importing values.
@imported_var = external global i32
@imported_var_addend = external global i32
@imported_var2 = external global i32
@imported_var3 = external global i32

; Test that an import is replaced with an addend.  Here, the addend is zero.
@reloc_var = global i32* @imported_var
; CHECK: @reloc_var = internal global [4 x i8] zeroinitializer

; Test that a constant import becomes a non-constant.
@reloc_var_const = constant i32* @imported_var
; CHECK: @reloc_var_const = internal global [4 x i8] zeroinitializer

; Test a non-zero addend.
@reloc_var_addend = global i32* getelementptr (i32, i32* @imported_var, i32 1)
; CHECK: @reloc_var_addend = internal global [4 x i8] c"\04\00\00\00"

; Test multiple imports within a single global variable initializer.
@reloc_var_offset = global [4 x i32*] [
    i32* null,
    i32* getelementptr (i32, i32* @imported_var2, i32 1),
    i32* getelementptr (i32, i32* @imported_var3, i32 2),
    i32* inttoptr (i32 255 to i32*)]
; CHECK: @reloc_var_offset = internal global [16 x i8] c"\00\00\00\00\04\00\00\00\08\00\00\00\FF\00\00\00"

; Test that a constant compound initializer becomes a non-constant.
@reloc_var_const_offset = constant [4 x i32*] [
    i32* null,
    i32* getelementptr (i32, i32* @imported_var2, i32 1),
    i32* getelementptr (i32, i32* @imported_var3, i32 2),
    i32* inttoptr (i32 255 to i32*)]
; CHECK: @reloc_var_const_offset = internal global [16 x i8] c"\00\00\00\00\04\00\00\00\08\00\00\00\FF\00\00\00"

; References to module-local variables should not be modified.
@local_var = internal global i32 0
@local_reloc_var = global i32* @local_var
; CHECK: @local_reloc_var = internal global i32 ptrtoint ([4 x i8]* @local_var to i32)
@local_reloc_var_addend = global i32* getelementptr (i32, i32* @local_var, i32 1)
; CHECK: @local_reloc_var_addend = internal global i32 add (i32 ptrtoint ([4 x i8]* @local_var to i32), i32 4)


; Variables that we expect the pass to define:

; This variable should be non-constant because it is filled out at load
; time.  Check for a specific size here to ensure that this doesn't import
; any symbols unnecessarily.
; CHECK: @__globals_table__ = internal global [12 x i8] zeroinitializer

; CHECK: @__pnacl_pso_root = constant


declare void @imported_func()

define void ()* @get_imported_func() {
  ret void ()* @imported_func
}
; CHECK: define internal i32 @get_imported_func()
; CHECK-NEXT: %__globals_table__.bc =
; CHECK-NEXT: %imported_func = load i32, i32* %__globals_table__.bc
; CHECK-NEXT: ret i32 %imported_func

define i32* @get_imported_var() {
  ret i32* @imported_var
}
; CHECK: define internal i32 @get_imported_var() {
; CHECK-NEXT: %expanded = ptrtoint {{.*}} @__globals_table__ to i32
; CHECK-NEXT: %gep = add i32 %expanded
; CHECK-NEXT: %gep.asptr = inttoptr i32 %gep to i32*
; CHECK-NEXT: %imported_var = load i32, i32* %gep.asptr
; CHECK-NEXT: ret i32 %imported_var

define i32* @get_imported_var_addend() {
  ret i32* getelementptr (i32, i32* @imported_var_addend, i32 1)
}
; CHECK: define internal i32 @get_imported_var_addend()
; CHECK-NEXT: %expanded = ptrtoint {{.*}} @__globals_table__ to i32
; CHECK-NEXT: %gep = add i32 %expanded
; CHECK-NEXT: %gep.asptr = inttoptr i32 %gep to i32*
; CHECK-NEXT: %imported_var_addend = load i32, i32* %gep.asptr
; CHECK-NEXT: %gep4 = add i32 %imported_var_addend, 4
; CHECK-NEXT: ret i32 %gep4
