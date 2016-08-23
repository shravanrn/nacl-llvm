/* Copyright 2016 The Native Client Authors. All rights reserved.
 * Use of this source code is governed by a BSD-style license that can
 * be found in the LICENSE file.
 */

//===-- pnacl-hack-memset.cpp - Fix (interim) Subzero bug -----------------===//
//
//===----------------------------------------------------------------------===//
//
// Fixes generated pexe's so that a Subzero bug (fixed but not yet fully
// deployed until 10/2016). Does this by replacing calls to memset with a
// constant (negative) byte value, and corresponding constant count arguments,
// with a zero-add to the count. This causes the broken (and fixed) optimization
// to not be fired.
//
//===----------------------------------------------------------------------===//

#include "llvm/Bitcode/NaCl/NaClReaderWriter.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/DataStream.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/Support/PrettyStackTrace.h"
#include "llvm/Support/Signals.h"
#include "llvm/Support/StreamingMemoryObject.h"
#include "llvm/Support/ToolOutputFile.h"

using namespace llvm;

namespace {

cl::opt<std::string>
OutputFilename("o", cl::desc("Specify fixed pexe filename"),
               cl::value_desc("fixed pexe file"), cl::init("-"));

cl::opt<std::string>
InputFilename(cl::Positional, cl::desc("<pexe file>"), cl::init("-"));

cl::opt<bool>
ShowFixes("show-fixes", cl::desc("Show fixes to memset"), cl::init(false));

void WriteOutputFile(const Module *M) {

  std::error_code EC;
  std::unique_ptr<tool_output_file> Out(
      new tool_output_file(OutputFilename, EC, sys::fs::F_None));
  if (EC) {
    errs() << EC.message() << '\n';
    exit(1);
  }

  NaClWriteBitcodeToFile(M, Out->os(), /* AcceptSupportedOnly = */ false);

  // Declare success.
  Out->keep();
}

Module *readBitcode(std::string &Filename, LLVMContext &Context,
                    std::string &ErrorMessage) {
  // Use the bitcode streaming interface
  DataStreamer *Streamer = getDataFileStreamer(InputFilename, &ErrorMessage);
  if (Streamer == nullptr)
    return nullptr;
  std::unique_ptr<StreamingMemoryObject> Buffer(
      new StreamingMemoryObjectImpl(Streamer));
  std::string DisplayFilename;
  if (Filename == "-")
    DisplayFilename = "<stdin>";
  else
    DisplayFilename = Filename;
  DiagnosticHandlerFunction DiagnosticHandler = nullptr;
  Module *M = getNaClStreamedBitcodeModule(
      DisplayFilename, Buffer.release(), Context, DiagnosticHandler,
      &ErrorMessage, /*AcceptSupportedOnly=*/false);
  if (!M)
    return nullptr;
  if (std::error_code EC = M->materializeAllPermanently()) {
    ErrorMessage = EC.message();
    delete M;
    return nullptr;
  }
  return M;
}

// Fixes the memset call if appropriate.  Returns 1 if the Call to memset has
// been fixed, and zero otherwise.
size_t fixCallToMemset(CallInst *Call) {
  if (Call->getNumArgOperands() != 5)
    return 0;
  Value *Val = Call->getArgOperand(1);
  auto *CVal = dyn_cast<ConstantInt>(Val);
  if (CVal == nullptr)
    return 0;
  if (!CVal->getType()->isIntegerTy(8))
    return 0;
  const APInt &IVal = CVal->getUniqueInteger();
  if (!IVal.isNegative())
    return 0;
  Value *Count = Call->getArgOperand(2);
  auto *CCount = dyn_cast<ConstantInt>(Count);
  if (CCount == nullptr)
    return 0;
  if (!CCount->getType()->isIntegerTy(32))
    return 0;
  if (ShowFixes) {
    Call->print(errs());
    errs() << "\n-->\n";
  }
  auto *Zero = ConstantInt::getSigned(CCount->getType(), 0);
  auto *Add = BinaryOperator::Create(Instruction::BinaryOps::Add, CCount, Zero);
  auto *IAdd = dyn_cast<Instruction>(Add);
  if (IAdd == nullptr)
    return 0;
  Call->setArgOperand(2, Add);
  IAdd->insertBefore(Call);
  if (ShowFixes) {
    IAdd->print(errs());
    errs() << "\n";
    Call->print(errs());
    errs() << "\n\n";
  }
  return 1;
}

// Fixes the instruction Inst, if it is a memset call that needs to be fixed.
// Returns 1 if the instruction Inst has been fixed, and zero otherwise.
size_t fixCallToMemset(Instruction *Inst) {
  size_t Count = 0;
  if (auto *Call = dyn_cast<CallInst>(Inst)) {
    if (Function *Fcn = Call->getCalledFunction()) {
      if ("llvm.memset.p0i8.i32" == Fcn->getName()) {
        Count += fixCallToMemset(Call);
      }
    }
  }
  return Count;
}

// Fixes appropriate memset calls in the basic Block.  Returns the number of
// fixed memset calls in the given basic Block.
size_t fixCallsToMemset(BasicBlock *Block) {
  size_t Count = 0;
  for (auto &Inst : *Block) {
    Count += fixCallToMemset(&Inst);
  }
  return Count;
}

// Fixes appropriate memset calls in the function Fcn.  Returns the number of
// fixed memset calls for the given function.
size_t fixCallsToMemset(Function *Fcn) {
  size_t Count = 0;
  for (auto &Block : *Fcn) {
    Count += fixCallsToMemset(&Block);
  }
  return Count;
}

// Fixes appropriate memset calls in module M> Returns the number of fixed
// memset calls.
size_t fixCallsToMemset(Module *M) {
  size_t ErrorCount = 0;
  for (auto &Fcn : *M) {
    if (!Fcn.isDeclaration())
      ErrorCount += fixCallsToMemset(&Fcn);
  }
  return ErrorCount;
}

} // end of anonymous namespace

int main(int argc, char **argv) {
  // Print a stack trace if we signal out.
  sys::PrintStackTraceOnErrorSignal();
  PrettyStackTraceProgram X(argc, argv);

  LLVMContext &Context = getGlobalContext();
  llvm_shutdown_obj Y;  // Call llvm_shutdown() on exit.

  cl::ParseCommandLineOptions(
      argc, argv, "Converts NaCl pexe wire format into LLVM bitcode format\n");

  std::string ErrorMessage;
  std::unique_ptr<Module> M(readBitcode(InputFilename, Context, ErrorMessage));

  if (!M.get()) {
    errs() << argv[0] << ": ";
    if (ErrorMessage.size())
      errs() << ErrorMessage << "\n";
    else
      errs() << "bitcode didn't read correctly.\n";
    return 1;
  }

  size_t ErrorCount = fixCallsToMemset(M.get());
  if (ErrorCount > 0) {
    errs() << argv[0] << ": Fixed " << ErrorCount << " calls to memset.\n";
  }

  WriteOutputFile(M.get());
  return 0;
}
