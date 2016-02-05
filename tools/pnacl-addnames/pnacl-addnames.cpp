/* Copyright 2013 The Native Client Authors. All rights reserved.
 * Use of this source code is governed by a BSD-style license that can
 * be found in the LICENSE file.
 */

//===-- pnacl-addnames.cpp - Adds symbol names to ABI-compliant pexe ------===//
//
//===----------------------------------------------------------------------===//
//
// Takes an ABI-compliant pexe and adds names for globals and functions to
// enable A/B debugging between llc and Subzero.
//
//===----------------------------------------------------------------------===//

#include "llvm/Bitcode/NaCl/NaClReaderWriter.h"
#include "llvm/Bitcode/ReaderWriter.h"
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
OutputFilename("o", cl::desc("Specify output filename"),
               cl::value_desc("filename"), cl::init("-"));

cl::opt<std::string>
InputFilename(cl::Positional, cl::desc("<pexe file>"), cl::init("-"));

void writeOutputFile(const Module *M) {
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

} // end of anonymous namespace

int main(int argc, char **argv) {
  // Print a stack trace if we signal out.
  sys::PrintStackTraceOnErrorSignal();
  PrettyStackTraceProgram X(argc, argv);

  LLVMContext &Context = getGlobalContext();
  llvm_shutdown_obj Y;  // Call llvm_shutdown() on exit.

  cl::ParseCommandLineOptions(argc, argv, "Adds global names to PNaCl pexe\n");

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

  uint32_t NameID = 0;
  // Give the functions names.
  for (auto &F : M->getFunctionList()) {
    constexpr char FunctionPrefix[] = "Function";
    if (F.getName().empty()) {
      F.setName(StringRef(FunctionPrefix + std::to_string(NameID)));
      ++NameID;
    }
  }
  // Give the global variables names.
  for (auto &GV : M->getGlobalList()) {
    constexpr char GlobalPrefix[] = "Global";
    if (GV.getName().empty()) {
      GV.setName(StringRef(GlobalPrefix + std::to_string(NameID)));
      ++NameID;
    }
  }

  // Write the file out.
  writeOutputFile(M.get());
  return 0;
}
