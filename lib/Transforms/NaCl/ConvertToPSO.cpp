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
//  * Importing symbols
//     * when referenced by global variable initializers
//     * when referenced by functions
//  * Building a hash table of exported symbols to allow O(1)-time lookup
//
// The following features are not implemented yet:
//
//  * Support for thread-local variables
//  * Support for lazy binding (i.e. lazy symbol resolution)
//
//===----------------------------------------------------------------------===//

#include "llvm/ADT/SmallString.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/Module.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/NaCl.h"

using namespace llvm;

namespace {
  // This version number can be incremented when the format of the PSO data
  // is changed in an incompatible way.
  //
  // For the time being, this is intended only as a convenience for making
  // cross-repo changes, because the PSO format is interpreted by code in
  // the native_client repo.  The PSO format is not intended to be stable
  // yet.
  //
  // If the format is changed in a compatible way, an alternative is to
  // increment TOOLCHAIN_FEATURE_VERSION instead.
  const int PSOFormatVersion = 2;

  // This is a ModulePass because it inherently operates on a whole module.
  class ConvertToPSO : public ModulePass {
  public:
    static char ID; // Pass identification, replacement for typeid
    ConvertToPSO() : ModulePass(ID) {
      initializeConvertToPSOPass(*PassRegistry::getPassRegistry());
    }

    virtual bool runOnModule(Module &M);
  };

  // This is Dan Bernstein's string hash algorithm.
  uint32_t hashString(const std::string &S) {
    uint32_t H = 5381;
    for (unsigned char Ch : S)
      H = H * 33 + Ch;
    return H;
  }

  class SymbolTableEntry {
  public:
    SymbolTableEntry(Constant *Val) :
      Value(Val), Hash(hashString(Value->getName())) {}

    Constant *Value;
    uint32_t Hash;
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

  // Set up an array as a Global Variable, given a SmallVector.
  Constant *createArray(Module &M, const char *Name,
                        SmallVectorImpl<Constant *> *Array,
                        Type *ElementType) {
    Constant *Contents = ConstantArray::get(
        ArrayType::get(ElementType, Array->size()), *Array);
    return new GlobalVariable(
        M, Contents->getType(), true, GlobalValue::InternalLinkage,
        Contents, Name);
  }

  Constant *createDataArray(Module &M, const char *Name,
                            SmallVectorImpl<uint32_t> *Array) {
    Constant *Contents = ConstantDataArray::get(M.getContext(), *Array);
    return new GlobalVariable(
        M, Contents->getType(), true, GlobalValue::InternalLinkage,
        Contents, Name);
  }

  // This function adds a level of indirection to references by functions
  // to imported GlobalValues.  Any time a function refers to a symbol that
  // is defined outside the module, we modify the function to read the
  // symbol's value from a global variable which we call the "globals
  // table".  The dynamic linker can then relocate the module by filling
  // out the globals table.
  //
  // For example, suppose we have a C library that contains this:
  //
  //   extern int imported_var;
  //
  //   int *get_imported_var() {
  //     return &imported_var;
  //   }
  //
  // We transform that code to the equivalent of this:
  //
  //   static void *__globals_table__[] = { &imported_var, ... };
  //
  //   int *get_imported_var() {
  //     return __globals_table__[0];
  //   }
  //
  // The relocation to "addr_of_imported_var" is then recorded by a later
  // part of the ConvertToPSO pass.
  //
  // The globals table does the same job as the Global Offset Table (GOT)
  // in ELF.  It is slightly different from the GOT because it is
  // implemented as a different level of abstraction.  In ELF, the GOT is a
  // linker feature.  Relocations can be relative to the GOT's base
  // address, and there can only be one GOT per ELF module.  The compiler
  // and assembler can generate GOT-relative relocations (when compiling
  // with "-fPIC"); the linker resolves these and generates the GOT.
  //
  // In contrast, in PNaCl the globals table is introduced at the level of
  // LLVM IR.  Unlike the GOT, the globals table is not special.  Nothing
  // needs to know about it outside this function.  (However, this would
  // change if we were to add support for lazy binding.)
  void buildGlobalsTable(Module &M) {
    // We need to replace some uses of GlobalValues with "load"
    // instructions, but that only works if functions don't contain
    // ConstantExprs referencing those GlobalValues, because we can't
    // modify a ConstantExpr to refer to an instruction.  To address this,
    // we first convert all ConstantExprs inside functions into
    // instructions by running the ExpandConstantExpr pass.
    FunctionPass *Pass = createExpandConstantExprPass();
    for (Function &Func : M.functions())
      Pass->runOnFunction(Func);
    delete Pass;

    // Search for all references to imported functions/variables by
    // functions.
    SmallVector<std::pair<Use *, unsigned>, 32> Refs;
    SmallVector<Constant *, 32> TableEntries;
    auto processGlobalValue = [&](GlobalValue &GV) {
      if (GV.isDeclaration()) {
        bool NeedsEntry = false;
        for (Use &U : GV.uses()) {
          if (isa<Instruction>(U.getUser())) {
            NeedsEntry = true;
            Refs.push_back(std::make_pair(&U, TableEntries.size()));
          }
        }
        if (NeedsEntry) {
          TableEntries.push_back(&GV);
        }
      }
    };
    for (Function &Func : M.functions()) {
      if (!Func.isIntrinsic())
        processGlobalValue(Func);
    }
    for (GlobalValue &Var : M.globals()) {
      processGlobalValue(Var);
    }

    if (TableEntries.empty())
      return;

    // Create a GlobalVariable for the globals table.
    Constant *TableData = ConstantStruct::getAnon(
        M.getContext(), TableEntries, true);
    auto TableVar = new GlobalVariable(
        M, TableData->getType(), false, GlobalValue::InternalLinkage,
        TableData, "__globals_table__");

    // Update use sites to load addresses from the globals table.
    for (auto &Ref : Refs) {
      Value *GV = Ref.first->get();
      Instruction *InsertPt = cast<Instruction>(Ref.first->getUser());
      Value *Indexes[] = {
        ConstantInt::get(M.getContext(), APInt(32, 0)),
        ConstantInt::get(M.getContext(), APInt(32, Ref.second)),
      };
      Value *TableEntryAddr = GetElementPtrInst::Create(
          TableData->getType(), TableVar, Indexes,
          GV->getName() + ".gt", InsertPt);
      Ref.first->set(new LoadInst(TableEntryAddr, GV->getName(), InsertPt));
    }
  }
}

char ConvertToPSO::ID = 0;
INITIALIZE_PASS(ConvertToPSO, "convert-to-pso",
                "Convert module to a PNaCl portable shared object (PSO)",
                false, false)

bool ConvertToPSO::runOnModule(Module &M) {
  LLVMContext &C = M.getContext();
  DataLayout DL(&M);
  Type *PtrType = Type::getInt8Ty(C)->getPointerTo();
  Type *IntPtrType = DL.getIntPtrType(C);

  buildGlobalsTable(M);

  // A table of strings which contains all imported and exported symbol names.
  SmallString<1024> StringTable;

  // Enters the name of a symbol into the string table, and record
  // the index at which the symbol is stored in the list of names.
  auto createSymbol = [&](SmallVectorImpl<Constant *> *NameOffsets,
                          SmallVectorImpl<Constant *> *ValuePtrs,
                          const StringRef Name, Constant *Addr) {
    // Identify the symbol's address (for exports) or the address which should
    // be updated to include the symbol (for imports).
    ValuePtrs->push_back(ConstantExpr::getBitCast(Addr, PtrType));
    // Identify the offset in the StringTable that will contain the symbol name.
    NameOffsets->push_back(ConstantInt::get(IntPtrType, StringTable.size()));

    // Copy the name into the string table, along with the null terminator.
    StringTable.append(Name);
    StringTable.push_back(0);
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
  SmallVector<Constant *, 32> ImportPtrs;
  // Indexes into the StringTable for the names of exported symbols.
  SmallVector<Constant *, 32> ImportNames;
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
            ConstantInt::get(C, APInt(32, 0)),
            ConstantInt::get(C, APInt(32, I)),
          };
          Constant *Addr = ConstantExpr::getGetElementPtr(
              Init->getType(), &Var, Indexes);
          createSymbol(&ImportNames, &ImportPtrs, GV->getName(), Addr);
          // Replace the original reference with the addend value.
          Element = ConstantInt::get(Element->getType(), Addend);
          Modified = true;
        }
        Elements.push_back(Element);
      }

      if (Modified) {
        // This global variable will need to be relocated at runtime, so it
        // should not be in read-only memory.
        Var.setConstant(false);
        // Note that the resulting initializer will not follow
        // FlattenGlobals' normal form, because it will contain i32s rather
        // than i8 arrays.  However, the later pass of FlattenGlobals will
        // restore the normal form.
        Var.setInitializer(ConstantStruct::getAnon(C, Elements, true));
      }
    } else {
      // The initializer is a single SimpleElement.
      uint64_t Addend;
      if (auto GV = getReference(Init, &Addend)) {
        createSymbol(&ImportNames, &ImportPtrs, GV->getName(), &Var);
        // This global variable will need to be relocated at runtime, so it
        // should not be in read-only memory.
        Var.setConstant(false);
        // Replace the original reference with the addend value.
        Var.setInitializer(ConstantInt::get(Init->getType(), Addend));
      }
    }
  }

  // This acts roughly like the ".dynsym" section of an ELF file.
  SmallVector<SymbolTableEntry, 32> ExportedSymbolTableVector;

  // Process exports.
  SmallVector<Constant *, 32> ExportPtrs;
  // Indexes into the StringTable for the names of exported symbols.
  SmallVector<Constant *, 32> ExportNames;

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

    // Actually store the pointer to be exported.
    ExportedSymbolTableVector.push_back(SymbolTableEntry(&GV));
    GV.setLinkage(GlobalValue::InternalLinkage);
  };

  for (Module::iterator Iter = M.begin(); Iter != M.end(); ) {
    processGlobalValue(*Iter++);
  }
  for (Module::global_iterator Iter = M.global_begin();
       Iter != M.global_end(); ) {
    processGlobalValue(*Iter++);
  }

  // The following section uses the ExportedSymbolTableVector to generate a hash
  // table, which, embeded in PSL Root, can be used to quickly look up symbols
  // based on a string name.
  //
  // The hash table is based on the GNU ELF hash section
  // (https://blogs.oracle.com/ali/entry/gnu_hash_elf_sections).
  //
  // Using the hash table requires the following function be known:
  //   uint32_t hashString(const char *str)
  //
  // The hash table contains the following fields:
  //   size_t NumBuckets
  //   int32_t *Buckets[0 ... NumBuckets]
  //   uint32_t *HashChains[0 ... NumChainEntries]
  // Where NumChainEntries is known to be the number of exported symbols.
  //
  // The hash table requires that the list of ExportNames is sorted by
  // "hashString(export_symbol) % NumBuckets".
  //
  // Given an input string, Str, a lookup is done as follows:
  // 1) H = hashString(Str) is calculated.
  // 2) BucketIndex = H % NumBuckets is calculated, as an index into the list of
  //    buckets.
  // 3) BucketValue = Buckets[BucketIndex] is calculated.
  //    BucketValue will be -1 if there are no exported symbols such that
  //      hashString(symbol.name) % NumBuckets = BucketIndex.
  //    BucketValue will be an index into the HashChains array if there is at
  //      least one symbol where hashString(symbol.name) % NumBuckets =
  //      BucketIndex.
  // 4) If BucketValue != -1, then BucketValue corresponds with an index to the
  //    start of a chain, identified as "ChainIndex".
  // 5) ChainIndex has a double meaning.
  //    Firstly, ChainIndex itself is an index into "ExportNames" (taking
  //      advantage of the sorting requirement stated earlier).
  //    Secondly, ChainValue = HashChains[ChainIndex] can be calculated.
  //    ChainValue also has a double meaning:
  //      The bottom bit (ChainValue & 1):
  //        This bit indicates if ExportNames[ChainIndex] is the last symbol
  //        with a name such that:
  //        BucketIndex == hashString(ExportNames[ChainIndex]) % NumBuckets
  //        In other words, this bit is 1 if ChainIndex is the end of a chain.
  //      The top 31 bits (ChainValue & ~1):
  //        The top 31 bits of ChainValue cache the hash of the corresonding
  //        symbol in export names:
  //        ChainValue = hashString(ExportNames[ChainIndex]) & ~1
  //        This hash can be used to quickly compare with "H".
  // 6) For each entry in the chain, (ChainValue & ~1) can be compared with
  //    (H & ~1) to quickly identify if "Str" matches the corresponding symbol
  //    at ExportNames[ChainIndex]. If the hashes match, the full strings are
  //    compared. If they do not, ChainIndex is incremented, and step (6) is
  //    repeated (unless the ChainIndex is the end of a chain, indicated by
  //    ChainValue & 1).
  //
  // TODO(smklein): Add a bloom filter for quick negative symbol lookups.

  const size_t NumChainEntries = ExportedSymbolTableVector.size();
  const size_t AverageChainLength = 4;
  const size_t NumBuckets = (NumChainEntries + AverageChainLength - 1)
      / AverageChainLength;

  // The SymbolTable must be sorted by hash(symbol name) % number of buckets
  // to allow quick access from the hash table.
  // Sort the table (as a vector), and then iterate through the symbols, adding
  // their names and values to the appropriate variable in the PSLRoot.
  auto sortStringTable = [&](const SymbolTableEntry &A,
                             const SymbolTableEntry &B) {
    return (A.Hash % NumBuckets) <
           (B.Hash % NumBuckets);
  };

  std::sort(ExportedSymbolTableVector.begin(), ExportedSymbolTableVector.end(),
            sortStringTable);

  SmallVector<uint32_t, 32> HashBuckets;
  HashBuckets.assign(NumBuckets, -1);

  SmallVector<uint32_t, 32> HashChains;
  HashChains.reserve(ExportPtrs.size());

  uint32_t PrevBucketNum = -1;
  for (size_t Index = 0; Index < ExportedSymbolTableVector.size(); ++Index) {
    const SymbolTableEntry *Element = &ExportedSymbolTableVector[Index];
    const uint32_t HashValue = Element->Hash;

    // The bottom bit of the chain value is reserved to identify if the element
    // is the "end of the chain" for the given (hash(name) % numbuckets) entry.
    uint32_t ChainValue = HashValue & ~1;
    // The final entry in the chain list should be marked as "end of chain".
    if (Index == ExportedSymbolTableVector.size() - 1)
      ChainValue |= 1;
    HashChains.push_back(ChainValue);

    uint32_t BucketNum = HashValue % NumBuckets;
    if (PrevBucketNum != BucketNum) {
      // We are starting a new hash chain.
      if (Index != 0) {
        // Mark the end of the previous hash chain.
        HashChains[Index - 1] |= 1;
      }
      // Record a pointer to the start of the new hash chain.
      HashBuckets[BucketNum] = Index;
      PrevBucketNum = BucketNum;
    }

    createSymbol(&ExportNames, &ExportPtrs, Element->Value->getName(),
                 Element->Value);
  }

  // This lets us remove the "NumChainEntries" field from the PsoRoot.
  assert(NumChainEntries == ExportPtrs.size() && "Malformed export hash table");

  // Set up string of exported names.
  Constant *StringTableArray = ConstantDataArray::getString(
      C, StringRef(StringTable.data(), StringTable.size()), false);
  Constant *StringTableVar = new GlobalVariable(
      M, StringTableArray->getType(), true, GlobalValue::InternalLinkage,
      StringTableArray, "string_table");

  Constant *PsoRoot[] = {
    ConstantInt::get(IntPtrType, PSOFormatVersion),

    // String Table
    StringTableVar,

    // Exports
    createArray(M, "export_ptrs", &ExportPtrs, PtrType),
    createArray(M, "export_names", &ExportNames, IntPtrType),
    ConstantInt::get(IntPtrType, ExportPtrs.size()),

    // Imports
    createArray(M, "import_ptrs", &ImportPtrs, PtrType),
    createArray(M, "import_names", &ImportNames, IntPtrType),
    ConstantInt::get(IntPtrType, ImportPtrs.size()),

    // Hash Table (for quick string lookup of exports)
    ConstantInt::get(IntPtrType, NumBuckets),
    createDataArray(M, "hash_buckets", &HashBuckets),
    createDataArray(M, "hash_chains", &HashChains),
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
