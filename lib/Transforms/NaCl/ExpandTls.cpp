//===- ExpandTls.cpp - Convert TLS variables to a concrete layout----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This pass expands out uses of thread-local (TLS) variables into
// more primitive operations.
//
// A reference to the address of a TLS variable is expanded into code
// which gets the current thread's thread pointer using
// @llvm.nacl.read.tp() and adds a fixed offset.
//
// This pass allocates the offsets (relative to the thread pointer)
// that will be used for TLS variables.  It sets up the global
// variables __tls_template_start, __tls_template_end etc. to contain
// a template for initializing TLS variables' values for each thread.
// This is a task normally performed by the linker in ELF systems.
//
// Layout:
//
// This currently uses an x86-style layout where the TLS variables are
// placed at addresses below the thread pointer (i.e. with negative offsets
// from the thread pointer).  See
// native_client/src/untrusted/nacl/tls_params.h for an explanation of
// different architectures' TLS layouts.
//
// This x86-style layout is *not* required for normal ABI-stable pexes.
//
// However, the x86-style layout is currently required for Non-SFI pexes
// that call x86 Linux syscalls directly.  This is a configuration that is
// only used for testing.
//
// Before PNaCl was launched, using x86-style layout used to be required
// because there was a check in nacl_irt_thread_create() (in
// irt/irt_thread.c) that required the thread pointer to be a self-pointer
// on x86-32.  That requirement was removed because it was non-portable
// (because it could cause a pexe to fail on x86 but not on ARM) -- see
// https://codereview.chromium.org/11411310.
//
//===----------------------------------------------------------------------===//

#include <vector>

#include "llvm/Pass.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/IR/Module.h"
#include "llvm/Transforms/NaCl.h"

using namespace llvm;

namespace {
  struct VarInfo {
    GlobalVariable *TlsVar;
    // Offset of the TLS variable.  Initially this is a non-negative offset
    // from the start of the TLS block.  After we adjust for the x86-style
    // layout, this becomes a negative offset from the thread pointer.
    uint32_t Offset;
  };

  class PassState {
  public:
    PassState(Module *M): M(M), DL(M), Offset(0), Alignment(1) {}

    Module *M;
    DataLayout DL;
    uint32_t Offset;
    // 'Alignment' is the maximum variable alignment seen so far, in
    // bytes.  After visiting all TLS variables, this is the overall
    // alignment required for the TLS template.
    uint32_t Alignment;
  };

  class ExpandTls : public ModulePass {
  public:
    static char ID; // Pass identification, replacement for typeid
    ExpandTls() : ModulePass(ID) {
      initializeExpandTlsPass(*PassRegistry::getPassRegistry());
    }

    virtual bool runOnModule(Module &M);
  };
}

char ExpandTls::ID = 0;
INITIALIZE_PASS(ExpandTls, "nacl-expand-tls",
                "Expand out TLS variables and fix TLS variable layout",
                false, false)

static void setGlobalVariableValue(Module &M, const char *Name,
                                   Constant *Value) {
  if (GlobalVariable *Var = M.getNamedGlobal(Name)) {
    if (Var->hasInitializer()) {
      report_fatal_error(std::string("Variable ") + Name +
                         " already has an initializer");
    }
    Var->replaceAllUsesWith(ConstantExpr::getBitCast(Value, Var->getType()));
    Var->eraseFromParent();
  }
}

// Insert alignment padding into the TLS template.
static void padToAlignment(PassState *State,
                           std::vector<Constant*> *FieldValues,
                           unsigned Alignment) {
  if ((State->Offset & (Alignment - 1)) != 0) {
    unsigned PadSize = Alignment - (State->Offset & (Alignment - 1));
    Type *i8 = Type::getInt8Ty(State->M->getContext());
    Type *PadType = ArrayType::get(i8, PadSize);
    if (FieldValues)
      FieldValues->push_back(Constant::getNullValue(PadType));
    State->Offset += PadSize;
  }
  if (State->Alignment < Alignment) {
    State->Alignment = Alignment;
  }
}

static uint32_t addVarToTlsTemplate(PassState *State,
                                    std::vector<Constant*> *FieldValues,
                                    GlobalVariable *TlsVar) {
  unsigned Alignment = State->DL.getPreferredAlignment(TlsVar);
  padToAlignment(State, FieldValues, Alignment);

  if (FieldValues)
    FieldValues->push_back(TlsVar->getInitializer());
  uint32_t Offset = State->Offset;
  State->Offset +=
      State->DL.getTypeAllocSize(TlsVar->getType()->getElementType());
  return Offset;
}

// This is similar to ConstantStruct::getAnon(), but we give a name to the
// struct type to make the IR output more readable.
static Constant *makeInitStruct(Module &M, ArrayRef<Constant *> Elements) {
  SmallVector<Type *, 32> FieldTypes;
  FieldTypes.reserve(Elements.size());
  for (Constant *Val : Elements)
    FieldTypes.push_back(Val->getType());

  // We create the TLS template struct as "packed" because we insert
  // alignment padding ourselves.
  StructType *Ty = StructType::create(M.getContext(), FieldTypes,
                                      "tls_init_template", /*isPacked=*/ true);
  return ConstantStruct::get(Ty, Elements);
}

static void buildTlsTemplate(Module &M, std::vector<VarInfo> *TlsVars) {
  std::vector<Constant*> FieldInitValues;
  PassState State(&M);

  for (GlobalVariable &GV : M.globals()) {
    if (GV.isThreadLocal()) {
      if (!GV.hasInitializer()) {
        // Since this is a whole-program transformation, "extern" TLS
        // variables are not allowed at this point.
        report_fatal_error(std::string("TLS variable without an initializer: ")
                           + GV.getName());
      }
      if (!GV.getInitializer()->isNullValue()) {
        VarInfo Info;
        Info.TlsVar = &GV;
        Info.Offset = addVarToTlsTemplate(&State, &FieldInitValues, &GV);
        TlsVars->push_back(Info);
      }
    }
  }
  uint32_t TemplateDataSize = State.Offset;
  // Handle zero-initialized TLS variables in a second pass, because
  // these should follow non-zero-initialized TLS variables.
  for (GlobalVariable &GV : M.globals()) {
    if (GV.isThreadLocal() && GV.getInitializer()->isNullValue()) {
      VarInfo Info;
      Info.TlsVar = &GV;
      Info.Offset = addVarToTlsTemplate(&State, NULL, &GV);
      TlsVars->push_back(Info);
    }
  }
  // Add final alignment padding so that
  //   (struct tls_struct *) __nacl_read_tp() - 1
  // gives the correct, aligned start of the TLS variables given the
  // x86-style layout we are using.  This requires some more bytes to
  // be memset() to zero at runtime.  This wastage doesn't seem
  // important gives that we're not trying to optimize packing by
  // reordering to put similarly-aligned variables together.
  padToAlignment(&State, NULL, State.Alignment);
  uint32_t TemplateTotalSize = State.Offset;

  // Adjust offsets for x86-style layout.
  for (VarInfo &VarInfo : *TlsVars)
    VarInfo.Offset -= TemplateTotalSize;

  // We define the following symbols, which are the same as those
  // defined by NaCl's original customized binutils linker scripts:
  //   __tls_template_start
  //   __tls_template_tdata_end
  //   __tls_template_end
  // We also define __tls_template_alignment, which was not defined by
  // the original linker scripts.

  const char *StartSymbol = "__tls_template_start";
  Constant *TemplateData = makeInitStruct(M, FieldInitValues);
  GlobalVariable *TemplateDataVar =
      new GlobalVariable(M, TemplateData->getType(), /*isConstant=*/true,
                         GlobalValue::InternalLinkage, TemplateData);
  setGlobalVariableValue(M, StartSymbol, TemplateDataVar);
  TemplateDataVar->setName(StartSymbol);

  Type *I8 = Type::getInt8Ty(M.getContext());
  Constant *TemplateAsI8 = ConstantExpr::getBitCast(TemplateDataVar,
                                                    I8->getPointerTo());

  Constant *TdataEnd = ConstantExpr::getGetElementPtr(
      I8, TemplateAsI8,
      ConstantInt::get(M.getContext(), APInt(32, TemplateDataSize)));
  setGlobalVariableValue(M, "__tls_template_tdata_end", TdataEnd);

  Constant *TotalEnd = ConstantExpr::getGetElementPtr(
      I8, TemplateAsI8,
      ConstantInt::get(M.getContext(), APInt(32, TemplateTotalSize)));
  setGlobalVariableValue(M, "__tls_template_end", TotalEnd);

  const char *AlignmentSymbol = "__tls_template_alignment";
  Type *i32 = Type::getInt32Ty(M.getContext());
  GlobalVariable *AlignmentVar = new GlobalVariable(
      M, i32, /*isConstant=*/true,
      GlobalValue::InternalLinkage,
      ConstantInt::get(M.getContext(), APInt(32, State.Alignment)));
  setGlobalVariableValue(M, AlignmentSymbol, AlignmentVar);
  AlignmentVar->setName(AlignmentSymbol);
}

static void rewriteTlsVars(Module &M, std::vector<VarInfo> *TlsVars) {
  // Set up the intrinsic that reads the thread pointer.
  Function *ReadTpFunc = Intrinsic::getDeclaration(&M, Intrinsic::nacl_read_tp);

  for (VarInfo &VarInfo : *TlsVars) {
    GlobalVariable *Var = VarInfo.TlsVar;
    while (!Var->use_empty()) {
      Use *U = &*Var->use_begin();
      Instruction *InsertPt = PhiSafeInsertPt(U);
      Value *ThreadPtr = CallInst::Create(ReadTpFunc, "thread_ptr", InsertPt);
      Value *IndexList[] = {
        ConstantInt::get(M.getContext(), APInt(32, VarInfo.Offset))
      };
      Value *TlsFieldI8 = GetElementPtrInst::Create(
          Type::getInt8Ty(M.getContext()),
          ThreadPtr, IndexList, Var->getName() + ".i8", InsertPt);
      Value *TlsField = new BitCastInst(TlsFieldI8, Var->getType(),
                                        Var->getName(), InsertPt);
      PhiSafeReplaceUses(U, TlsField);
    }
    Var->eraseFromParent();
  }
}

static void replaceFunction(Module &M, const char *Name, Value *NewFunc) {
  if (Function *Func = M.getFunction(Name)) {
    if (Func->hasLocalLinkage())
      return;
    if (!Func->isDeclaration())
      report_fatal_error(std::string("Function already defined: ") + Name);
    Func->replaceAllUsesWith(NewFunc);
    Func->eraseFromParent();
  }
}

// Provide fixed definitions for NaCl's TLS layout functions,
// __nacl_tp_*().  We adopt the x86-style layout: ExpandTls will
// output a program that uses the x86-style layout wherever it runs.
//
// This overrides the architecture-specific definitions of
// __nacl_tp_*() that PNaCl's native support code makes available to
// non-ABI-stable code.
static void defineTlsLayoutFunctions(Module &M) {
  Type *i32 = Type::getInt32Ty(M.getContext());
  SmallVector<Type*, 1> ArgTypes;
  ArgTypes.push_back(i32);
  FunctionType *FuncType = FunctionType::get(i32, ArgTypes, /*isVarArg=*/false);
  Function *NewFunc;
  BasicBlock *BB;

  // Define the function as follows:
  //   uint32_t __nacl_tp_tdb_offset(uint32_t tdb_size) {
  //     return 0;
  //   }
  // This means the thread pointer points to the TDB.
  NewFunc = Function::Create(FuncType, GlobalValue::InternalLinkage,
                             "nacl_tp_tdb_offset", &M);
  BB = BasicBlock::Create(M.getContext(), "entry", NewFunc);
  ReturnInst::Create(M.getContext(),
                     ConstantInt::get(M.getContext(), APInt(32, 0)), BB);
  replaceFunction(M, "__nacl_tp_tdb_offset", NewFunc);

  // Define the function as follows:
  //   uint32_t __nacl_tp_tls_offset(uint32_t tls_size) {
  //     return -tls_size;
  //   }
  // This means the TLS variables are stored below the thread pointer.
  NewFunc = Function::Create(FuncType, GlobalValue::InternalLinkage,
                             "nacl_tp_tls_offset", &M);
  BB = BasicBlock::Create(M.getContext(), "entry", NewFunc);
  Value *Arg = NewFunc->arg_begin();
  Arg->setName("size");
  Value *Result = BinaryOperator::CreateNeg(Arg, "result", BB);
  ReturnInst::Create(M.getContext(), Result, BB);
  replaceFunction(M, "__nacl_tp_tls_offset", NewFunc);
}

bool ExpandTls::runOnModule(Module &M) {
  ModulePass *Pass = createExpandTlsConstantExprPass();
  Pass->runOnModule(M);
  delete Pass;

  std::vector<VarInfo> TlsVars;
  buildTlsTemplate(M, &TlsVars);
  rewriteTlsVars(M, &TlsVars);

  defineTlsLayoutFunctions(M);

  return true;
}

ModulePass *llvm::createExpandTlsPass() {
  return new ExpandTls();
}
