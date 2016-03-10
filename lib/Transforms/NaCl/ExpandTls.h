//===-- ExpandTls.h - Convert TLS variables to a concrete layout-*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef TRANSFORMS_NACL_EXPANDTLS_H
#define TRANSFORMS_NACL_EXPANDTLS_H

#include <stdint.h>

#include <vector>

#include "llvm/IR/Constants.h"
#include "llvm/IR/Module.h"

namespace llvm {

struct TlsVarInfo {
  GlobalVariable *TlsVar;
  // Offset of the TLS variable.  Initially this is a non-negative offset
  // from the start of the TLS block.  After we adjust for the x86-style
  // layout, this becomes a negative offset from the thread pointer.
  uint32_t Offset;
};

struct TlsTemplate {
  std::vector<TlsVarInfo> TlsVars;
  Constant *Data;
  uint32_t DataSize;
  uint32_t TotalSize;
  uint32_t Alignment;
};

void buildTlsTemplate(Module &M, TlsTemplate *Result);

}

#endif
