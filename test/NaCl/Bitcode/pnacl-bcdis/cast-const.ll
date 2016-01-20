; Fixes issue
; https://bugs.chromium.org/p/nativeclient/issues/detail?id=4353. Checks that we
; type elided pointer casts, when the elided value is a constant.

; RUN: llvm-as < %s | pnacl-freeze | pnacl-bcdis -no-records | FileCheck %s

define internal float @foo() {
  %vaddr = inttoptr i32 0 to float*
  %v = load float, float* %vaddr, align 1
  ret float %v
}

; CHECK:      module {  // BlockID = 8
; CHECK-NEXT:   version 1;
; CHECK-NEXT:   abbreviations {  // BlockID = 0
; CHECK-NEXT:     valuesymtab:
; CHECK-NEXT:       @a0 = abbrev <fixed(3), vbr(8), array(fixed(8))>;
; CHECK-NEXT:       @a1 = abbrev <1, vbr(8), array(fixed(7))>;
; CHECK-NEXT:       @a2 = abbrev <1, vbr(8), array(char6)>;
; CHECK-NEXT:       @a3 = abbrev <2, vbr(8), array(char6)>;
; CHECK-NEXT:     constants:
; CHECK-NEXT:       @a0 = abbrev <1, fixed(3)>;
; CHECK-NEXT:       @a1 = abbrev <4, vbr(8)>;
; CHECK-NEXT:       @a2 = abbrev <4, 0>;
; CHECK-NEXT:       @a3 = abbrev <6, vbr(8)>;
; CHECK-NEXT:     function:
; CHECK-NEXT:       @a0 = abbrev <20, vbr(6), vbr(4), vbr(4)>;
; CHECK-NEXT:       @a1 = abbrev <2, vbr(6), vbr(6), fixed(4)>;
; CHECK-NEXT:       @a2 = abbrev <3, vbr(6), fixed(3), fixed(4)>;
; CHECK-NEXT:       @a3 = abbrev <10>;
; CHECK-NEXT:       @a4 = abbrev <10, vbr(6)>;
; CHECK-NEXT:       @a5 = abbrev <15>;
; CHECK-NEXT:       @a6 = abbrev <43, vbr(6), fixed(3)>;
; CHECK-NEXT:       @a7 = abbrev <24, vbr(6), vbr(6), vbr(4)>;
; CHECK-NEXT:     globals:
; CHECK-NEXT:       @a0 = abbrev <0, vbr(6), fixed(1)>;
; CHECK-NEXT:       @a1 = abbrev <1, vbr(8)>;
; CHECK-NEXT:       @a2 = abbrev <2, vbr(8)>;
; CHECK-NEXT:       @a3 = abbrev <3, array(fixed(8))>;
; CHECK-NEXT:       @a4 = abbrev <4, vbr(6)>;
; CHECK-NEXT:       @a5 = abbrev <4, vbr(6), vbr(6)>;
; CHECK-NEXT:   }
; CHECK-NEXT:   types {  // BlockID = 17
; CHECK-NEXT:     %a0 = abbrev <21, fixed(1), array(fixed(3))>;
; CHECK-NEXT:     count 4;
; CHECK-NEXT:     @t0 = float;
; CHECK-NEXT:     @t1 = float (); <%a0>
; CHECK-NEXT:     @t2 = i32;
; CHECK-NEXT:     @t3 = void;
; CHECK-NEXT:   }
; CHECK-NEXT:   define internal float @f0();
; CHECK-NEXT:   globals {  // BlockID = 19
; CHECK-NEXT:     count 0;
; CHECK-NEXT:   }
; CHECK-NEXT:   valuesymtab {  // BlockID = 14
; CHECK-NEXT:     @f0 : "foo"; <@a2>
; CHECK-NEXT:   }
; CHECK-NEXT:   function float @f0() {  // BlockID = 12
; CHECK-NEXT:     blocks 1;
; CHECK-NEXT:     constants {  // BlockID = 11
; CHECK-NEXT:       i32: <@a0>
; CHECK-NEXT:         %c0 = i32 0; <@a2>
; CHECK-NEXT:       }
; CHECK-NEXT:   %b0:
; CHECK-NEXT:     %v0 = load float* %c0, align 1; <@a0>
; CHECK-NEXT:     ret float %v0; <@a4>
; CHECK-NEXT:   }
; CHECK-NEXT: }
