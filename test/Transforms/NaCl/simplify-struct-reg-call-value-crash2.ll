; RUN: opt < %s -simplify-struct-reg-signatures -S
target datalayout = "e-p:32:32-i64:64-n32"
target triple = "le32-unknown-nacl"

%0 = type { %1, %0*, i32 }
%1 = type { [128 x i64] }
%2 = type { %3, i32, i32 }
%3 = type { %4, %5 }
%4 = type { i8* }
%5 = type {}
%ExceptionFrame = type { [1024 x i8], %ExceptionFrame*, i32 }

@__pnacl_eh_stack = thread_local global %0* null, align 4
@llvm.global_ctors = appending global [1 x { i32, void ()*, i8* }] [{ i32, void ()*, i8* } { i32 65535, void ()* null, i8* null }]

; Function Attrs: uwtable
define fastcc void @_ZN3ffi5c_str7CString3new20h1938757535082073330E(i32) unnamed_addr #0 {
  %invoke_frame = alloca %ExceptionFrame, align 8
  %exc_info_ptr = getelementptr %ExceptionFrame, %ExceptionFrame* %invoke_frame, i32 0, i32 2
  %invoke_next = getelementptr %ExceptionFrame, %ExceptionFrame* %invoke_frame, i32 0, i32 1
  %invoke_jmp_buf = getelementptr %ExceptionFrame, %ExceptionFrame* %invoke_frame, i32 0, i32 0, i32 0
  %expanded = bitcast %0** @__pnacl_eh_stack to %ExceptionFrame**
  %pnacl_eh_stack = bitcast %ExceptionFrame** %expanded to %ExceptionFrame**
  %old_eh_stack = load %ExceptionFrame*, %ExceptionFrame** %pnacl_eh_stack
  store %ExceptionFrame* %old_eh_stack, %ExceptionFrame** %invoke_next
  store i32 1, i32* %exc_info_ptr
  store %ExceptionFrame* %invoke_frame, %ExceptionFrame** %pnacl_eh_stack
  %invoke_is_exc = call i32 @_ZN3ffi5c_str7CString3new20h1938757535082073330E_setjmp_caller(%2* null, i32 %0, void (%2*, i32)* null, i8* %invoke_jmp_buf)
  store %ExceptionFrame* %old_eh_stack, %ExceptionFrame** %pnacl_eh_stack
  %invoke_sj_is_zero = icmp eq i32 %invoke_is_exc, 0
  br i1 %invoke_sj_is_zero, label %5, label %2

; <label>:2                                       ; preds = %1
  %landingpad_ptr = bitcast i8* %invoke_jmp_buf to { i8*, i32 }*
  %3 = load { i8*, i32 }, { i8*, i32 }* %landingpad_ptr
  %resume_exc = extractvalue { i8*, i32 } %3, 0
  %resume_cast = bitcast i8* %resume_exc to i8*
  call void @__pnacl_eh_resume(i8* %resume_cast)
  unreachable

; <label>:4                                       ; preds = %8, %8, %10, %11
  %resume_exc1 = extractvalue { i8*, i32 } undef, 0
  %resume_cast2 = bitcast i8* %resume_exc1 to i8*
  call void @__pnacl_eh_resume(i8* %resume_cast2)
  unreachable

; <label>:5                                       ; preds = %1
  br i1 undef, label %6, label %.critedge

.critedge:                                        ; preds = %5, %.critedge
  %.pr = phi i1 [ false, %5 ], [ undef, %.critedge ]
  br i1 %.pr, label %13, label %.critedge

; <label>:6                                       ; preds = %5
  %old_eh_stack3 = load %ExceptionFrame*, %ExceptionFrame** %pnacl_eh_stack
  store %ExceptionFrame* %old_eh_stack3, %ExceptionFrame** %invoke_next
  store i32 1, i32* %exc_info_ptr
  store %ExceptionFrame* %invoke_frame, %ExceptionFrame** %pnacl_eh_stack
  %invoke_is_exc4 = call i32 @_ZN3ffi5c_str7CString3new20h1938757535082073330E_setjmp_caller1(%2* undef, void (%2*)* null, i8* %invoke_jmp_buf)
  store %ExceptionFrame* %old_eh_stack3, %ExceptionFrame** %pnacl_eh_stack
  %invoke_sj_is_zero5 = icmp eq i32 %invoke_is_exc4, 0
  br i1 %invoke_sj_is_zero5, label %7, label %8

; <label>:7                                       ; preds = %6
  %old_eh_stack6 = load %ExceptionFrame*, %ExceptionFrame** %pnacl_eh_stack
  store %ExceptionFrame* %old_eh_stack6, %ExceptionFrame** %invoke_next
  store i32 1, i32* %exc_info_ptr
  store %ExceptionFrame* %invoke_frame, %ExceptionFrame** %pnacl_eh_stack
  %invoke_is_exc7 = call i32 @_ZN3ffi5c_str7CString3new20h1938757535082073330E_setjmp_caller2(%2* undef, { i8*, i32 } (%2*)* null, i8* %invoke_jmp_buf)
  store %ExceptionFrame* %old_eh_stack6, %ExceptionFrame** %pnacl_eh_stack
  %invoke_sj_is_zero8 = icmp eq i32 %invoke_is_exc7, 0
  br i1 %invoke_sj_is_zero8, label %13, label %8

; <label>:8                                       ; preds = %7, %6
  %landingpad_ptr12 = bitcast i8* %invoke_jmp_buf to { i8*, i32 }*
  %9 = load { i8*, i32 }, { i8*, i32 }* %landingpad_ptr12
  switch i32 undef, label %10 [
    i32 488447261, label %4
    i32 0, label %4
  ]

; <label>:10                                      ; preds = %8
  %old_eh_stack9 = load %ExceptionFrame*, %ExceptionFrame** %pnacl_eh_stack
  store %ExceptionFrame* %old_eh_stack9, %ExceptionFrame** %invoke_next
  store i32 1, i32* %exc_info_ptr
  store %ExceptionFrame* %invoke_frame, %ExceptionFrame** %pnacl_eh_stack
  %invoke_is_exc10 = call i32 @_ZN3ffi5c_str7CString3new20h1938757535082073330E_setjmp_caller3(i8* undef, i32 undef, i32 0, void (i8*, i32, i32)* null, i8* %invoke_jmp_buf)
  store %ExceptionFrame* %old_eh_stack9, %ExceptionFrame** %pnacl_eh_stack
  %invoke_sj_is_zero11 = icmp eq i32 %invoke_is_exc10, 0
  br i1 %invoke_sj_is_zero11, label %4, label %11

; <label>:11                                      ; preds = %10
  %landingpad_ptr13 = bitcast i8* %invoke_jmp_buf to { i8*, i32 }*
  %12 = load { i8*, i32 }, { i8*, i32 }* %landingpad_ptr13
  br label %4

; <label>:13                                      ; preds = %7, %.critedge
  ret void
}

define internal i32 @_ZN3ffi5c_str7CString3new20h1938757535082073330E_setjmp_caller3(i8* %arg, i32 %arg1, i32 %arg2, void (i8*, i32, i32)* %func_ptr, i8* %jmp_buf) {
  %invoke_sj = call i32 @llvm.nacl.setjmp(i8* %jmp_buf) #3
  %invoke_sj_is_zero = icmp eq i32 %invoke_sj, 0
  br i1 %invoke_sj_is_zero, label %normal, label %exception

normal:                                           ; preds = %0
  call void %func_ptr(i8* %arg, i32 %arg1, i32 %arg2)
  ret i32 0

exception:                                        ; preds = %0
  ret i32 1
}

define internal i32 @_ZN3ffi5c_str7CString3new20h1938757535082073330E_setjmp_caller2(%2* %arg, { i8*, i32 } (%2*)* %func_ptr, i8* %jmp_buf) {
  %invoke_sj = call i32 @llvm.nacl.setjmp(i8* %jmp_buf) #3
  %invoke_sj_is_zero = icmp eq i32 %invoke_sj, 0
  br i1 %invoke_sj_is_zero, label %normal, label %exception

normal:                                           ; preds = %0
  %1 = call fastcc { i8*, i32 } %func_ptr(%2* noalias nocapture dereferenceable(12) %arg)
  ret i32 0

exception:                                        ; preds = %0
  ret i32 1
}

define internal i32 @_ZN3ffi5c_str7CString3new20h1938757535082073330E_setjmp_caller1(%2* %arg, void (%2*)* %func_ptr, i8* %jmp_buf) {
  %invoke_sj = call i32 @llvm.nacl.setjmp(i8* %jmp_buf) #3
  %invoke_sj_is_zero = icmp eq i32 %invoke_sj, 0
  br i1 %invoke_sj_is_zero, label %normal, label %exception

normal:                                           ; preds = %0
  call fastcc void %func_ptr(%2* noalias dereferenceable(12) %arg)
  ret i32 0

exception:                                        ; preds = %0
  ret i32 1
}

; Function Attrs: noreturn
declare void @__pnacl_eh_resume(i8*) #1

define internal i32 @_ZN3ffi5c_str7CString3new20h1938757535082073330E_setjmp_caller(%2* %arg, i32 %arg1, void (%2*, i32)* %func_ptr, i8* %jmp_buf) {
  %invoke_sj = call i32 @llvm.nacl.setjmp(i8* %jmp_buf) #3
  %invoke_sj_is_zero = icmp eq i32 %invoke_sj, 0
  br i1 %invoke_sj_is_zero, label %normal, label %exception

normal:                                           ; preds = %0
  call fastcc void %func_ptr(%2* noalias dereferenceable(12) %arg, i32 %arg1)
  ret i32 0

exception:                                        ; preds = %0
  ret i32 1
}

; Function Attrs: nounwind
declare i32 @llvm.nacl.setjmp(i8*) #2

attributes #0 = { uwtable }
attributes #1 = { noreturn }
attributes #2 = { nounwind }
attributes #3 = { returns_twice }
