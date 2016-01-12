//===- ConvertToPSO.cpp - Convert module to a PNaCl PSO--------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// The ConvertToPSO pass is part of an implementation of dynamic
// linking for PNaCl.  It transforms an LLVM module to be a PNaCl PSO
// (portable shared object).
//
// This pass takes symbol information that's stored at the LLVM IR
// level and moves it to be stored inside variables within the module,
// in a data structure rooted at the "__pnacl_pso_root" variable.
//
// This means that when the module is dynamically loaded, a runtime
// dynamic linker can read the "__pnacl_pso_root" data structure to
// look up symbols that the module exports and supply definitions of
// symbols that a module imports.
//
// Currently, this pass only implements exporting of symbols.  The
// following features are not implemented yet:
//
//  * Importing symbols
//  * Building a hash table of exported symbols to allow O(1)-time lookup
//  * Support for thread-local variables
//
//===----------------------------------------------------------------------===//

#include "llvm/IR/Constants.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/Module.h"
#include "llvm/Pass.h"
#include "llvm/Transforms/NaCl.h"

using namespace llvm;

namespace {
  // This is a ModulePass because it inherently operates on a whole module.
  class ConvertToPSO : public ModulePass {
  public:
    static char ID; // Pass identification, replacement for typeid
    ConvertToPSO() : ModulePass(ID) {
      initializeConvertToPSOPass(*PassRegistry::getPassRegistry());
    }

    virtual bool runOnModule(Module &M);
  };
}

char ConvertToPSO::ID = 0;
INITIALIZE_PASS(ConvertToPSO, "convert-to-pso",
                "Convert module to a PNaCl portable shared object (PSO)",
                false, false)

bool ConvertToPSO::runOnModule(Module &M) {
  DataLayout DL(&M);
  Type *PtrType = Type::getInt8Ty(M.getContext())->getPointerTo();
  Type *IntPtrType = DL.getIntPtrType(M.getContext());

  SmallVector<Constant *, 32> ExportNames;
  SmallVector<Constant *, 32> ExportPtrs;

  auto processGlobalValue = [&](GlobalValue &GV) {
    if (GV.isDeclaration() ||
        GV.getLinkage() != GlobalValue::ExternalLinkage)
      return;

    // Make a copy of the name to add a null terminator.
    StringRef Name = GV.getName();
    std::string NameWithNull;
    NameWithNull.reserve(Name.size() + 1);
    NameWithNull = Name;
    NameWithNull.push_back(0);
    const uint8_t *NameData =
        reinterpret_cast<const uint8_t *>(NameWithNull.data());
    Constant *Str = ConstantDataArray::get(
        M.getContext(),
        ArrayRef<uint8_t>(NameData, NameData + NameWithNull.size()));
    Constant *StrVar = new GlobalVariable(M, Str->getType(), true,
                                          GlobalValue::InternalLinkage,
                                          Str, "export_str");
    ExportNames.push_back(ConstantExpr::getBitCast(StrVar, PtrType));
    ExportPtrs.push_back(ConstantExpr::getBitCast(&GV, PtrType));
    GV.setLinkage(GlobalValue::InternalLinkage);
  };

  for (Function &Func : M.functions())
    processGlobalValue(Func);
  for (GlobalValue &Var : M.globals())
    processGlobalValue(Var);

  // Set up array of exported symbol names.
  Constant *ExportNamesArray = ConstantArray::get(
      ArrayType::get(PtrType, ExportNames.size()), ExportNames);
  Constant *ExportNamesVar = new GlobalVariable(
      M, ExportNamesArray->getType(), true, GlobalValue::InternalLinkage,
      ExportNamesArray, "export_names");

  // Set up array of exported symbol values.
  Constant *ExportPtrsArray = ConstantArray::get(
      ArrayType::get(PtrType, ExportPtrs.size()), ExportPtrs);
  Constant *ExportPtrsVar = new GlobalVariable(
      M, ExportPtrsArray->getType(), true, GlobalValue::InternalLinkage,
      ExportPtrsArray, "export_ptrs");

  Constant *PsoRoot[] = {
    ExportPtrsVar,
    ExportNamesVar,
    ConstantInt::get(IntPtrType, ExportPtrs.size()),
  };
  Constant *PsoRootConst = ConstantStruct::getAnon(PsoRoot);
  new GlobalVariable(
      M, PsoRootConst->getType(), true, GlobalValue::ExternalLinkage,
      PsoRootConst, "__pnacl_pso_root");

  return true;
}

ModulePass *llvm::createConvertToPSOPass() {
  return new ConvertToPSO();
}
