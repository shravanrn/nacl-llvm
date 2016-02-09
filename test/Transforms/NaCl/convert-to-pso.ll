; This tests that the output of "-convert-to-pso" passes PNaCl's ABI verifier.
; RUN: opt < %s -convert-to-pso -pnacl-abi-simplify-postopt \
; RUN:     -verify-pnaclabi-module -verify-pnaclabi-functions -S | FileCheck %s

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


; Test importing values.
@imported_var = external global i32
@imported_var_addend = external global i32
@imported_var2 = external global i32
@imported_var3 = external global i32

; Test that an import is replaced with an addend.  Here, the addend is zero.
@reloc_var = global i32* @imported_var
; CHECK: @reloc_var = internal global [4 x i8] zeroinitializer

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

; References to module-local variables should not be modified.
@local_var = internal global i32 0
@local_reloc_var = global i32* @local_var
; CHECK: @local_reloc_var = internal global i32 ptrtoint ([4 x i8]* @local_var to i32)


; CHECK: @__pnacl_pso_root = constant
