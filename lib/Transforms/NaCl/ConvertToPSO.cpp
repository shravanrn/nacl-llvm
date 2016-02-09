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
// Currently, this pass implements:
//
//  * Exporting symbols
//  * Importing symbols when referenced by global variable initializers
//
// The following features are not implemented yet:
//
//  * Importing symbols when referenced by functions
//  * Building a hash table of exported symbols to allow O(1)-time lookup
//  * Support for thread-local variables
//
//===----------------------------------------------------------------------===//

#include "llvm/IR/Constants.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/Module.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"
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

  // This takes a SimpleElement from FlattenGlobals' normal form.  If the
  // SimpleElement is a reference to a GlobalValue, it returns the
  // GlobalValue along with its addend.  Otherwise, it returns nullptr.
  GlobalValue *getReference(Constant *Init, uint64_t *Addend) {
    *Addend = 0;
    if (isa<ArrayType>(Init->getType()))
      return nullptr;
    if (auto CE = dyn_cast<ConstantExpr>(Init)) {
      if (CE->getOpcode() == Instruction::Add) {
        if (auto CI = dyn_cast<ConstantInt>(CE->getOperand(1))) {
          if (auto Op0 = dyn_cast<ConstantExpr>(CE->getOperand(0))) {
            CE = Op0;
            *Addend = CI->getSExtValue();
          }
        }
      }
      if (CE->getOpcode() == Instruction::PtrToInt) {
        if (auto GV = dyn_cast<GlobalValue>(CE->getOperand(0))) {
          if (!GV->isDeclaration())
            return nullptr;
          return GV;
        }
      }
    }
    errs() << "Initializer value not handled: " << *Init << "\n";
    report_fatal_error("ConvertToPSO: Value is not a SimpleElement");
  }
}

char ConvertToPSO::ID = 0;
INITIALIZE_PASS(ConvertToPSO, "convert-to-pso",
                "Convert module to a PNaCl portable shared object (PSO)",
                false, false)

bool ConvertToPSO::runOnModule(Module &M) {
  DataLayout DL(&M);
  Type *PtrType = Type::getInt8Ty(M.getContext())->getPointerTo();
  Type *IntPtrType = DL.getIntPtrType(M.getContext());

  // Creates a new GlobalVariable containing the name of Val.  Uses Name
  // for the name of the GlobalVariable.
  auto createNameString = [&](Value *Val, const char *Name) {
    Constant *Str = ConstantDataArray::getString(
        M.getContext(), Val->getName());
    Constant *StrVar = new GlobalVariable(M, Str->getType(), true,
                                          GlobalValue::InternalLinkage,
                                          Str, Name);
    return ConstantExpr::getBitCast(StrVar, PtrType);
  };

  // In order to simplify the task of processing relocations inside
  // GlobalVariables' initializers, we first run the FlattenGlobals pass to
  // reduce initializers to a simple normal form.  This reduces the number
  // of cases we need to handle, and it allows us to iterate over the
  // initializers instead of needing to recurse.
  ModulePass *Pass = createFlattenGlobalsPass();
  Pass->runOnModule(M);
  delete Pass;

  // Process imports.
  SmallVector<Constant *, 32> ImportNames;
  SmallVector<Constant *, 32> ImportPtrs;
  for (GlobalVariable &Var : M.globals()) {
    if (!Var.hasInitializer())
      continue;
    Constant *Init = Var.getInitializer();
    if (auto CS = dyn_cast<ConstantStruct>(Init)) {
      // The initializer is a CompoundElement (i.e. a struct containing
      // SimpleElements).
      SmallVector<Constant *, 32> Elements;
      bool Modified = false;

      for (unsigned I = 0; I < CS->getNumOperands(); ++I) {
        Constant *Element = CS->getOperand(I);
        uint64_t Addend;
        if (auto GV = getReference(Element, &Addend)) {
          // Calculate the address that needs relocating.
          Value *Indexes[] = {
            ConstantInt::get(M.getContext(), APInt(32, 0)),
            ConstantInt::get(M.getContext(), APInt(32, I)),
          };
          Constant *Addr = ConstantExpr::getGetElementPtr(
              Init->getType(), &Var, Indexes);
          // Record the relocation.
          ImportPtrs.push_back(ConstantExpr::getBitCast(Addr, PtrType));
          ImportNames.push_back(createNameString(GV, "import_str"));
          // Replace the original reference with the addend value.
          Element = ConstantInt::get(Element->getType(), Addend);
          Modified = true;
        }
        Elements.push_back(Element);
      }

      if (Modified) {
        // Note that the resulting initializer will not follow
        // FlattenGlobals' normal form, because it will contain i32s rather
        // than i8 arrays.  However, the later pass of FlattenGlobals will
        // restore the normal form.
        Var.setInitializer(
            ConstantStruct::getAnon(M.getContext(), Elements, true));
      }
    } else {
      // The initializer is a single SimpleElement.
      uint64_t Addend;
      if (auto GV = getReference(Init, &Addend)) {
        // Record the relocation.
        ImportPtrs.push_back(ConstantExpr::getBitCast(&Var, PtrType));
        ImportNames.push_back(createNameString(GV, "import_str"));
        // Replace the original reference with the addend value.
        Var.setInitializer(ConstantInt::get(Init->getType(), Addend));
      }
    }
  }

  // Process exports.
  SmallVector<Constant *, 32> ExportNames;
  SmallVector<Constant *, 32> ExportPtrs;

  auto processGlobalValue = [&](GlobalValue &GV) {
    if (GV.isDeclaration()) {
      // Aside from intrinsics, we should have handled any imported
      // references already.
      if (auto Func = dyn_cast<Function>(&GV)) {
        if (Func->isIntrinsic())
          return;
      }
      GV.removeDeadConstantUsers();
      assert(GV.use_empty());
      GV.eraseFromParent();
      return;
    }

    if (GV.getLinkage() != GlobalValue::ExternalLinkage)
      return;

    ExportNames.push_back(createNameString(&GV, "export_str"));
    ExportPtrs.push_back(ConstantExpr::getBitCast(&GV, PtrType));
    GV.setLinkage(GlobalValue::InternalLinkage);
  };

  for (Module::iterator Iter = M.begin(); Iter != M.end(); ) {
    processGlobalValue(*Iter++);
  }
  for (Module::global_iterator Iter = M.global_begin();
       Iter != M.global_end(); ) {
    processGlobalValue(*Iter++);
  }

  // Set up an array of pointers.
  auto createArray = [&](const char *Name,
                         SmallVectorImpl<Constant *> *Array) -> Constant * {
    Constant *Contents = ConstantArray::get(
        ArrayType::get(PtrType, Array->size()), *Array);
    return new GlobalVariable(
        M, Contents->getType(), true, GlobalValue::InternalLinkage,
        Contents, Name);
  };

  Constant *PsoRoot[] = {
    // Exports
    createArray("export_ptrs", &ExportPtrs),
    createArray("export_names", &ExportNames),
    ConstantInt::get(IntPtrType, ExportPtrs.size()),
    // Imports
    createArray("import_ptrs", &ImportPtrs),
    createArray("import_names", &ImportNames),
    ConstantInt::get(IntPtrType, ImportPtrs.size()),
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
