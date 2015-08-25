; RUN: opt %s -simplify-struct-reg-signatures -expand-getelementptr -S

; Check that the type mapping used in -simplify-struct-reg-signatures doesn't
; crash -expand-getelementptr later on.

target datalayout = "e-p:32:32-i64:64-n32"
target triple = "le32-unknown-nacl"

%"3.core::fmt::ArgumentV1.40.622" = type { %"3.core::fmt::Void.4.586"*, i8 (%"3.core::fmt::Void.4.586"*, %"3.core::fmt::Formatter.42.624"*)* }
%"3.core::fmt::Void.4.586" = type {}
%"3.core::fmt::Formatter.42.624" = type { i32, i32, i8, %"3.core::fmt::rt::v1::Position.36.618", %"3.core::fmt::rt::v1::Position.36.618", { i8*, void (i8*)** }, %"3.core::slice::Iter<core::fmt::ArgumentV1>.41.623", { %"3.core::fmt::ArgumentV1.40.622"*, i32 } }
%"3.core::fmt::rt::v1::Position.36.618" = type { i32, [0 x i32], [1 x i32] }
%"3.core::slice::Iter<core::fmt::ArgumentV1>.41.623" = type { %"3.core::fmt::ArgumentV1.40.622"*, %"3.core::fmt::ArgumentV1.40.622"*, %"3.core::fmt::Void.4.586" }
%"3.core::fmt::Arguments.45.627" = type { { %str_slice.0.582*, i32 }, %"3.core::option::Option<&'static [core::fmt::rt::v1::Argument]>.44.626", { %"3.core::fmt::ArgumentV1.40.622"*, i32 } }
%"3.core::option::Option<&'static [core::fmt::rt::v1::Argument]>.44.626" = type { { %"3.core::fmt::rt::v1::Argument.38.620"*, i32 } }
%str_slice.0.582 = type { i8*, i32 }
%"3.core::fmt::rt::v1::Argument.38.620" = type { %"3.core::fmt::rt::v1::Position.36.618", %"3.core::fmt::rt::v1::FormatSpec.37.619" }
%"3.core::fmt::rt::v1::FormatSpec.37.619" = type { i32, i8, i32, %"3.core::fmt::rt::v1::Position.36.618", %"3.core::fmt::rt::v1::Position.36.618" }

; Function Attrs: uwtable
define internal void @"_ZN3fmt24ArgumentV1$LT$$u27$a$GT$3new20h5569056031325157823E"(%"3.core::fmt::ArgumentV1.40.622"* noalias nocapture sret dereferenceable(8), i8* noalias readonly dereferenceable(1), i8 (i8*, %"3.core::fmt::Formatter.42.624"*)*) unnamed_addr #0 {
entry-block:
  ret void
}

; Function Attrs: inlinehint nounwind uwtable
define internal void @"_ZN3fmt23Arguments$LT$$u27$a$GT$16new_v1_formatted20h7a57159fb067ccaaEoOE"(%"3.core::fmt::Arguments.45.627"* noalias nocapture sret dereferenceable(24), %str_slice.0.582* noalias nonnull readonly, i32, %"3.core::fmt::ArgumentV1.40.622"* noalias nonnull readonly, i32, %"3.core::fmt::rt::v1::Argument.38.620"* noalias nonnull readonly, i32) unnamed_addr #1 {
entry-block:
  %args.sroa.0.0..sroa_idx = getelementptr inbounds %"3.core::fmt::Arguments.45.627", %"3.core::fmt::Arguments.45.627"* %0, i32 0, i32 2, i32 0
  ret void
}

attributes #0 = { uwtable "no-frame-pointer-elim"="true" }
attributes #1 = { inlinehint nounwind uwtable }
