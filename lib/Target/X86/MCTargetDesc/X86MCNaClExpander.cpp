//===- X86MCNaClExpander.cpp ------------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the X86MCNaClExpander class, the X86 specific
// subclass of MCNaClExpander.
//
//===----------------------------------------------------------------------===//
#include "X86MCNaClExpander.h"
#include "X86BaseInfo.h"

#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCInstrDesc.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCNaClExpander.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCStreamer.h"

using namespace llvm;

static const int kBundleSize = 32;

unsigned getReg32(unsigned Reg);
unsigned getReg64(unsigned Reg);

static unsigned demoteOpcode(unsigned Reg);

static bool isAbsoluteReg(unsigned Reg) {
  Reg = getReg64(Reg); // Normalize to 64 bits
  return (Reg == X86::R15 || Reg == X86::RSP || Reg == X86::RBP ||
          Reg == X86::RIP);
}

void X86::X86MCNaClExpander::expandIndirectBranch(const MCInst &Inst,
                                                  MCStreamer &Out,
                                                  const MCSubtargetInfo &STI) {
  bool ThroughMemory = false, isCall = false;
  switch (Inst.getOpcode()) {
  case X86::CALL16m:
  case X86::CALL32m:
    ThroughMemory = true;
  case X86::CALL16r:
  case X86::CALL32r:
    isCall = true;
    break;
  case X86::JMP16m:
  case X86::JMP32m:
    ThroughMemory = true;
  case X86::JMP16r:
  case X86::JMP32r:
    break;
  default:
    llvm_unreachable("invalid indirect jmp/call");
  }

  MCOperand Target;
  if (ThroughMemory) {
    if (numScratchRegs() == 0)
      Error(Inst, "No scratch registers specified");

    Target = MCOperand::CreateReg(getReg32(getScratchReg(0)));

    MCInst Mov;
    Mov.setOpcode(X86::MOV32rm);
    Mov.addOperand(Target);
    Mov.addOperand(Inst.getOperand(0)); // Base
    Mov.addOperand(Inst.getOperand(1)); // Scale
    Mov.addOperand(Inst.getOperand(2)); // Index
    Mov.addOperand(Inst.getOperand(3)); // Offset
    Mov.addOperand(Inst.getOperand(4)); // Segment
    Out.EmitInstruction(Mov, STI);
  } else {
    Target = MCOperand::CreateReg(getReg32(Inst.getOperand(0).getReg()));
  }

  Out.EmitBundleLock(isCall);

  MCInst And;
  And.setOpcode(X86::AND32ri8);
  And.addOperand(Target);
  And.addOperand(Target);
  And.addOperand(MCOperand::CreateImm(-kBundleSize));
  Out.EmitInstruction(And, STI);

  MCInst Branch;
  Branch.setOpcode(isCall ? X86::CALL32r : X86::JMP32r);
  Branch.addOperand(Target);
  Out.EmitInstruction(Branch, STI);

  Out.EmitBundleUnlock();
}

// Expands the ret instruction.
void X86::X86MCNaClExpander::expandReturn(const MCInst &Inst, MCStreamer &Out,
                                          const MCSubtargetInfo &STI) {
  if (numScratchRegs() == 0)
    Error(Inst, "No scratch registers specified.");

  MCOperand ScratchReg = MCOperand::CreateReg(getReg32(getScratchReg(0)));
  MCInst Pop;
  Pop.setOpcode(X86::POP32r);
  Pop.addOperand(ScratchReg);
  Out.EmitInstruction(Pop, STI);

  if (Inst.getNumOperands() > 0) {
    assert(Inst.getOpcode() == X86::RETIL);
    MCInst Add;
    Add.setOpcode(X86::ADD32ri);
    Add.addOperand(MCOperand::CreateReg(X86::ESP));
    Add.addOperand(MCOperand::CreateReg(X86::ESP));
    Add.addOperand(Inst.getOperand(0));
    Out.EmitInstruction(Add, STI);
  }

  MCInst Jmp;
  Jmp.setOpcode(X86::JMP32r);
  Jmp.addOperand(ScratchReg);
  expandIndirectBranch(Jmp, Out, STI);
}

// Emits movl Reg32, Reg32
// Used as a helper in various places.
static void clearHighBits(const MCOperand &Reg, MCStreamer &Out,
                          const MCSubtargetInfo &STI) {
  MCInst Mov;
  Mov.setOpcode(X86::MOV32rr);
  MCOperand Op = MCOperand::CreateReg(getReg32(Reg.getReg()));

  Mov.addOperand(Op);
  Mov.addOperand(Op);
  Out.EmitInstruction(Mov, STI);
}

// Emits the sandboxing operations necessary, and modifies the memory
// operand specified by MemIdx.
// Used as a helper function for emitSandboxMemOps.
void X86::X86MCNaClExpander::emitSandboxMemOp(MCInst &Inst, int MemIdx,
                                              unsigned ScratchReg,
                                              MCStreamer &Out,
                                              const MCSubtargetInfo &STI) {
  MCOperand &Base = Inst.getOperand(MemIdx);
  MCOperand &Scale = Inst.getOperand(MemIdx + 1);
  MCOperand &Index = Inst.getOperand(MemIdx + 2);
  MCOperand &Offset = Inst.getOperand(MemIdx + 3);
  MCOperand &Segment = Inst.getOperand(MemIdx + 4);

  
  // In the cases below, we want to promote any registers in the
  // memory operand to 64 bits.
  if (isAbsoluteReg(Base.getReg()) && Index.getReg() == 0) {
    Base.setReg(getReg64(Base.getReg()));
  } else if (Base.getReg() == 0 && isAbsoluteReg(Index.getReg()) &&
             Scale.getImm() == 1) {
    Base.setReg(getReg64(Index.getReg()));
    Index.setReg(0);
  } else if (isAbsoluteReg(Base.getReg()) && !isAbsoluteReg(Index.getReg())) {
    clearHighBits(Index, Out, STI);
    Base.setReg(getReg64(Base.getReg()));
    Index.setReg(getReg64(Index.getReg()));
  } else if (Index.getReg() == 0) {
    clearHighBits(Base, Out, STI);
    Index.setReg(getReg64(Base.getReg()));
    Base.setReg(X86::R15);
  } else {
    unsigned Scratch32 = 0;
    if (ScratchReg != 0)
      Scratch32 = getReg32(ScratchReg);
    else
      Error(Inst, "Not enough scratch registers specified");

    unsigned Scratch64 = getReg64(Scratch32);
    unsigned BaseReg64 = getReg64(Base.getReg());
    unsigned IndexReg64 = getReg64(Index.getReg());

    MCInst Lea;
    Lea.setOpcode(X86::LEA64_32r);
    Lea.addOperand(MCOperand::CreateReg(Scratch32));
    Lea.addOperand(MCOperand::CreateReg(BaseReg64));
    Lea.addOperand(Scale);
    Lea.addOperand(MCOperand::CreateReg(IndexReg64));
    Lea.addOperand(Offset);
    Lea.addOperand(Segment);

    // Specical case if there is no base or scale
    if (Base.getReg() == 0 && Scale.getImm() == 1) {
      Lea.getOperand(1).setReg(IndexReg64); // Base
      Lea.getOperand(3).setReg(0);          // Index
    }

    Out.EmitInstruction(Lea, STI);

    Base.setReg(X86::R15);
    Scale.setImm(1);
    Index.setReg(Scratch64);
    Offset.setImm(0);
  }
}

// Returns true if sandboxing the memory operand specified at Idx of
// Inst will emit any auxillary instructions.
// Used in emitSandboxMemOps as a helper.
static bool willEmitSandboxInsts(const MCInst &Inst, int Idx) {
  const MCOperand &Base = Inst.getOperand(Idx);
  const MCOperand &Scale = Inst.getOperand(Idx + 1);
  const MCOperand &Index = Inst.getOperand(Idx + 2);

  if (isAbsoluteReg(Base.getReg()) && Index.getReg() == 0) {
    return false;
  } else if (Base.getReg() == 0 && isAbsoluteReg(Index.getReg()) &&
             Scale.getImm() == 1) {
    return false;
  }

  return true;
}

// Emits the instructions that are used to sandbox the memory operands.
// Modifies memory operands of Inst in place, but does NOT EMIT Inst.
// If any instructions are emitted, it will precede them with a .bundle_lock
// Returns true if any instructions were emitted, otherwise false.
// Note that this method can modify Inst, but still return false if no
// auxiliary sandboxing instructions were emitted.
bool X86::X86MCNaClExpander::emitSandboxMemOps(MCInst &Inst,
                                               unsigned ScratchReg,
                                               MCStreamer &Out,
                                               const MCSubtargetInfo &STI) {

  const MCOperandInfo *OpInfo = InstInfo->get(Inst.getOpcode()).OpInfo;

  bool anyInstsEmitted = false;

  for (int i = 0, e = Inst.getNumOperands(); i < e; ++i) {
    if (OpInfo[i].OperandType == MCOI::OPERAND_MEMORY) {
      if (!anyInstsEmitted && willEmitSandboxInsts(Inst, i)) {
        Out.EmitBundleLock(false);
        anyInstsEmitted = true;
      }
      emitSandboxMemOp(Inst, i, ScratchReg, Out, STI);
      i += 4;
    }
  }

  return anyInstsEmitted;
}

// Expands any operations that load to or store from memory, but do
// not explicitly modify the stack or base pointer.
void X86::X86MCNaClExpander::expandLoadStore(const MCInst &Inst,
                                             MCStreamer &Out,
                                             const MCSubtargetInfo &STI,
                                             bool EmitPrefixes) {
  assert(!explicitlyModifiesRegister(Inst, X86::RBP));
  assert(!explicitlyModifiesRegister(Inst, X86::RSP));

  // Optimize if we are doing a mov into a register
  bool ElideScratchReg = false;
  switch (Inst.getOpcode()) {
  case X86::MOV64rm:
  case X86::MOV32rm:
  case X86::MOV16rm:
  case X86::MOV8rm:
    ElideScratchReg = true;
  default:
    break;
  }

  MCInst SandboxedInst(Inst);

  unsigned ScratchReg;
  if (ElideScratchReg)
    ScratchReg = Inst.getOperand(0).getReg();
  else if (numScratchRegs() > 0)
    ScratchReg = getScratchReg(0);
  else
    ScratchReg = 0;

  bool BundleLock = emitSandboxMemOps(SandboxedInst, ScratchReg, Out, STI);
  emitInstruction(SandboxedInst, Out, STI, EmitPrefixes);
  if (BundleLock)
    Out.EmitBundleUnlock();
}

static bool isStringOperation(const MCInst &Inst) {
  switch (Inst.getOpcode()) {
  case X86::CMPSB:
  case X86::CMPSW:
  case X86::CMPSL:
  case X86::CMPSQ:
  case X86::MOVSB:
  case X86::MOVSW:
  case X86::MOVSL:
  case X86::MOVSQ:
  case X86::STOSB:
  case X86::STOSW:
  case X86::STOSL:
  case X86::STOSQ:
    return true;
  }
  return false;
}

static void fixupStringOpReg(const MCOperand &Op, MCStreamer &Out,
                             const MCSubtargetInfo &STI) {
  clearHighBits(Op, Out, STI);

  MCInst Lea;
  Lea.setOpcode(X86::LEA64r);
  Lea.addOperand(MCOperand::CreateReg(getReg64(Op.getReg())));
  Lea.addOperand(MCOperand::CreateReg(X86::R15));
  Lea.addOperand(MCOperand::CreateImm(1));
  Lea.addOperand(MCOperand::CreateReg(getReg64(Op.getReg())));
  Lea.addOperand(MCOperand::CreateImm(0));
  Lea.addOperand(MCOperand::CreateReg(0));
  Out.EmitInstruction(Lea, STI);
}

void X86::X86MCNaClExpander::expandStringOperation(const MCInst &Inst,
                                                   MCStreamer &Out,
                                                   const MCSubtargetInfo &STI,
						   bool EmitPrefixes) {
  Out.EmitBundleLock(false);
  switch (Inst.getOpcode()) {
  case X86::CMPSB:
  case X86::CMPSW:
  case X86::CMPSL:
  case X86::CMPSQ:
  case X86::MOVSB:
  case X86::MOVSW:
  case X86::MOVSL:
  case X86::MOVSQ:
    fixupStringOpReg(Inst.getOperand(0), Out, STI);
    fixupStringOpReg(Inst.getOperand(1), Out, STI);
    break;
  case X86::STOSB:
  case X86::STOSW:
  case X86::STOSL:
  case X86::STOSQ:
    fixupStringOpReg(Inst.getOperand(0), Out, STI);
    break;
  }
  emitInstruction(Inst, Out, STI, EmitPrefixes);
  Out.EmitBundleUnlock();
}

static void demoteInst(MCInst &Inst, const MCInstrInfo &InstInfo) {
  unsigned NewOpc = demoteOpcode(Inst.getOpcode());
  Inst.setOpcode(NewOpc);

  // demote all general purpose 64 bit registers to 32 bits
  const MCOperandInfo *OpInfo = InstInfo.get(Inst.getOpcode()).OpInfo;
  for (int i = 0, e = Inst.getNumOperands(); i < e; ++i) {
    if (OpInfo[i].OperandType == MCOI::OPERAND_REGISTER) {
      assert(Inst.getOperand(i).isReg());
      unsigned Reg = Inst.getOperand(i).getReg();
      if (getReg64(Reg) == Reg) {
        Inst.getOperand(i).setReg(getReg32(Reg));
      }
    }
  }
}

static void emitStackFixup(unsigned StackReg, MCStreamer &Out,
                           const MCSubtargetInfo &STI) {
  MCInst Lea;
  Lea.setOpcode(X86::LEA64r);
  Lea.addOperand(MCOperand::CreateReg(StackReg));
  Lea.addOperand(MCOperand::CreateReg(StackReg));
  Lea.addOperand(MCOperand::CreateImm(1));
  Lea.addOperand(MCOperand::CreateReg(X86::R15));
  Lea.addOperand(MCOperand::CreateImm(0));
  Lea.addOperand(MCOperand::CreateReg(0));
  Out.EmitInstruction(Lea, STI);
}

void X86::X86MCNaClExpander::expandExplicitStackManipulation(
    unsigned StackReg, const MCInst &Inst, MCStreamer &Out,
    const MCSubtargetInfo &STI, bool EmitPrefixes) {
  // First, handle special cases where sandboxing is not required.
  // Pop, push are not handled because %rsp or %rbp is not explicitly
  // defined
  if (Inst.getOpcode() == X86::MOV64rr) {
    unsigned SrcReg = Inst.getOperand(1).getReg();
    if (SrcReg == X86::RSP || SrcReg == X86::RBP)
      return emitInstruction(Inst, Out, STI, EmitPrefixes);
  } else if (Inst.getOpcode() == X86::AND64ri8) {
    int Imm = Inst.getOperand(2).getImm();
    if (-128 <= Imm && Imm <= -1 && StackReg == X86::RSP)
      return emitInstruction(Inst, Out, STI, EmitPrefixes);
  }
  MCInst SandboxedInst(Inst);
  demoteInst(SandboxedInst, *InstInfo);

  unsigned ScratchReg;
  if (numScratchRegs() > 0)
    ScratchReg = getScratchReg(0);
  else
    ScratchReg = 0;

  bool MemSandboxed = emitSandboxMemOps(SandboxedInst, ScratchReg, Out, STI);

  Out.EmitBundleLock(false); // for stack fixup

  emitInstruction(SandboxedInst, Out, STI, EmitPrefixes);
  if (MemSandboxed)
    Out.EmitBundleUnlock(); // for memory reference
  emitStackFixup(StackReg, Out, STI);

  Out.EmitBundleUnlock(); // for stack fixup
}

// Returns true if Inst is an X86 prefix
static bool isPrefix(const MCInst &Inst) {
  switch (Inst.getOpcode()) {
  case X86::LOCK_PREFIX:
  case X86::REP_PREFIX:
  case X86::REPNE_PREFIX:
  case X86::REX64_PREFIX:
    return true;
  default:
    return false;
  }
}

// returns the stack register that is used in xchg instruction
static unsigned XCHGStackReg(const MCInst &Inst) {
  unsigned Reg1 = 0, Reg2 = 0;
  switch (Inst.getOpcode()) {
  case X86::XCHG64ar:
  case X86::XCHG64rm:
    Reg1 = Inst.getOperand(0).getReg();
    break;
  case X86::XCHG64rr:
    Reg1 = Inst.getOperand(0).getReg();
    Reg2 = Inst.getOperand(2).getReg();
    break;
  default:
    return 0;
  }
  if (Reg1 == X86::RSP || Reg1 == X86::RBP)
    return Reg1;
  
  if (Reg2 == X86::RSP || Reg2 == X86::RBP)
    return Reg2;

  return 0;
}

// Emit prefixes + instruction if EmitPrefixes argument is true.
// Otherwise, emit the bare instruction.
void X86::X86MCNaClExpander::emitInstruction(const MCInst &Inst,
                                             MCStreamer &Out,
                                             const MCSubtargetInfo &STI,
                                             bool EmitPrefixes) {
  if (EmitPrefixes) {
    for (const MCInst &Prefix : Prefixes)
      Out.EmitInstruction(Prefix, STI);
    Prefixes.clear();
  }
  Out.EmitInstruction(Inst, STI);
}

void X86::X86MCNaClExpander::doExpandInst(const MCInst &Inst, MCStreamer &Out,
                                          const MCSubtargetInfo &STI,
                                          bool EmitPrefixes) {

  // Explicitly IGNORE all pseudo instructions, these will be handled in the
  // older customExpandInst code
  switch (Inst.getOpcode()) {
  case X86::CALLpcrel32:
  case X86::CALL64pcrel32:
  case X86::NACL_CALL64d:
  case X86::NACL_CALL32r:
  case X86::NACL_CALL64r:
  case X86::NACL_JMP32r:
  case X86::NACL_JMP64r:
  case X86::NACL_JMP64z:
  case X86::NACL_RET32:
  case X86::NACL_RET64:
  case X86::NACL_RETI32:
  case X86::NACL_ASPi8:
  case X86::NACL_ASPi32:
  case X86::NACL_SSPi8:
  case X86::NACL_SSPi32:
  case X86::NACL_ANDSPi8:
  case X86::NACL_ANDSPi32:
  case X86::NACL_SPADJi32:
  case X86::NACL_RESTBPm:
  case X86::NACL_RESTBPr:
  case X86::NACL_RESTBPrz:
  case X86::NACL_RESTSPm:
  case X86::NACL_RESTSPr:
  case X86::NACL_RESTSPrz:
    emitInstruction(Inst, Out, STI, EmitPrefixes);
    return;
  default:
    break;
  }
  for (int i = 0, e = Inst.getNumOperands(); i != e; ++i) {
    const MCOperand &Op = Inst.getOperand(i);
    if (Op.isReg() && Op.getReg() == X86::PSEUDO_NACL_SEG)
      return emitInstruction(Inst, Out, STI, EmitPrefixes);
  }
  if (isPrefix(Inst)) {
    return Prefixes.push_back(Inst);
  }
  // Don't handle 64 bit control flow expansions for now
  else if (!Is64Bit) {
    switch (Inst.getOpcode()) {
    case X86::CALL16r:
    case X86::CALL32r:
    case X86::CALL16m:
    case X86::CALL32m:
    case X86::JMP16r:
    case X86::JMP32r:
    case X86::JMP16m:
    case X86::JMP32m:
      return expandIndirectBranch(Inst, Out, STI);
    case X86::RETL:
    case X86::RETIL:
      return expandReturn(Inst, Out, STI);
    }
  }
  if (Is64Bit && isStringOperation(Inst)) {
    expandStringOperation(Inst, Out, STI, EmitPrefixes);
  } else if (Is64Bit && explicitlyModifiesRegister(Inst, X86::RSP)) {
    expandExplicitStackManipulation(X86::RSP, Inst, Out, STI, EmitPrefixes);
  } else if (Is64Bit && explicitlyModifiesRegister(Inst, X86::RBP)) {
    expandExplicitStackManipulation(X86::RBP, Inst, Out, STI, EmitPrefixes);
  } else if (unsigned StackReg = XCHGStackReg(Inst)) {
    // the above case doesnt catch xchg instruction, so special case
    expandExplicitStackManipulation(StackReg, Inst, Out, STI, EmitPrefixes);
  } else if (Is64Bit && (mayLoad(Inst) || mayStore(Inst))) {
    return expandLoadStore(Inst, Out, STI, EmitPrefixes);
  } else {
    emitInstruction(Inst, Out, STI, EmitPrefixes);
  }
}

bool X86::X86MCNaClExpander::expandInst(const MCInst &Inst, MCStreamer &Out,
                                        const MCSubtargetInfo &STI) {
  if (Guard)
    return false;
  Guard = true;

  doExpandInst(Inst, Out, STI, true);

  Guard = false;
  return true;
}

static unsigned demoteOpcode(unsigned Opcode) {
  switch (Opcode) {
  case X86::ADC64rr:
    return X86::ADC32rr;
  case X86::ADC64ri8:
    return X86::ADC32ri8;
  case X86::ADC64ri32:
    return X86::ADC32ri;
  case X86::ADC64rm:
    return X86::ADC32rm;
  case X86::ADCX64rr:
    return X86::ADCX32rr;
  case X86::ADCX64rm:
    return X86::ADCX32rm;
  case X86::ADD64rr:
    return X86::ADD32rr;
  case X86::ADD64ri8:
    return X86::ADD32ri8;
  case X86::ADD64ri32:
    return X86::ADD32ri;
  case X86::ADD64rm:
    return X86::ADD32rm;
  case X86::ADOX64rr:
    return X86::ADOX32rr;
  case X86::ADOX64rm:
    return X86::ADOX32rm;
  case X86::ANDN64rr:
    return X86::ANDN32rr;
  case X86::ANDN64rm:
    return X86::ANDN32rm;
  case X86::AND64rr:
    return X86::AND32rr;
  case X86::AND64ri8:
    return X86::AND32ri8;
  case X86::AND64ri32:
    return X86::AND32ri;
  case X86::AND64rm:
    return X86::AND32rm;
  case X86::BEXTRI64ri:
    return X86::BEXTRI32ri;
  case X86::BEXTRI64mi:
    return X86::BEXTRI32mi;
  case X86::BEXTR64rr:
    return X86::BEXTR32rr;
  case X86::BEXTR64rm:
    return X86::BEXTR32rm;
  case X86::BLCFILL64rr:
    return X86::BLCFILL32rr;
  case X86::BLCFILL64rm:
    return X86::BLCFILL32rm;
  case X86::BLCI64rr:
    return X86::BLCI32rr;
  case X86::BLCI64rm:
    return X86::BLCI32rm;
  case X86::BLCIC64rr:
    return X86::BLCIC32rr;
  case X86::BLCIC64rm:
    return X86::BLCIC32rm;
  case X86::BLCMSK64rr:
    return X86::BLCMSK32rr;
  case X86::BLCMSK64rm:
    return X86::BLCMSK32rm;
  case X86::BLCS64rr:
    return X86::BLCS32rr;
  case X86::BLCS64rm:
    return X86::BLCS32rm;
  case X86::BLSFILL64rr:
    return X86::BLSFILL32rr;
  case X86::BLSFILL64rm:
    return X86::BLSFILL32rm;
  case X86::BLSIC64rr:
    return X86::BLSIC32rr;
  case X86::BLSIC64rm:
    return X86::BLSIC32rm;
  case X86::BLSI64rr:
    return X86::BLSI32rr;
  case X86::BLSI64rm:
    return X86::BLSI32rm;
  case X86::BLSMSK64rr:
    return X86::BLSMSK32rr;
  case X86::BLSMSK64rm:
    return X86::BLSMSK32rm;
  case X86::BLSR64rr:
    return X86::BLSR32rr;
  case X86::BLSR64rm:
    return X86::BLSR32rm;
  case X86::BSF64rr:
    return X86::BSF32rr;
  case X86::BSF64rm:
    return X86::BSF32rm;
  case X86::BSR64rr:
    return X86::BSR32rr;
  case X86::BSR64rm:
    return X86::BSR32rm;
  case X86::BSWAP64r:
    return X86::BSWAP32r;
  case X86::BTC64rr:
    return X86::BTC32rr;
  case X86::BTC64ri8:
    return X86::BTC32ri8;
  case X86::BT64rr:
    return X86::BT32rr;
  case X86::BT64ri8:
    return X86::BT32ri8;
  case X86::BTR64rr:
    return X86::BTR32rr;
  case X86::BTR64ri8:
    return X86::BTR32ri8;
  case X86::BTS64rr:
    return X86::BTS32rr;
  case X86::BTS64ri8:
    return X86::BTS32ri8;
  case X86::BZHI64rr:
    return X86::BZHI32rr;
  case X86::BZHI64rm:
    return X86::BZHI32rm;
  case X86::CALL64r:
    return X86::CALL32r;
  case X86::XOR64rr:
    return X86::XOR32rr;
  case X86::CMOVAE64rr:
    return X86::CMOVAE32rr;
  case X86::CMOVAE64rm:
    return X86::CMOVAE32rm;
  case X86::CMOVA64rr:
    return X86::CMOVA32rr;
  case X86::CMOVA64rm:
    return X86::CMOVA32rm;
  case X86::CMOVBE64rr:
    return X86::CMOVBE32rr;
  case X86::CMOVBE64rm:
    return X86::CMOVBE32rm;
  case X86::CMOVB64rr:
    return X86::CMOVB32rr;
  case X86::CMOVB64rm:
    return X86::CMOVB32rm;
  case X86::CMOVE64rr:
    return X86::CMOVE32rr;
  case X86::CMOVE64rm:
    return X86::CMOVE32rm;
  case X86::CMOVGE64rr:
    return X86::CMOVGE32rr;
  case X86::CMOVGE64rm:
    return X86::CMOVGE32rm;
  case X86::CMOVG64rr:
    return X86::CMOVG32rr;
  case X86::CMOVG64rm:
    return X86::CMOVG32rm;
  case X86::CMOVLE64rr:
    return X86::CMOVLE32rr;
  case X86::CMOVLE64rm:
    return X86::CMOVLE32rm;
  case X86::CMOVL64rr:
    return X86::CMOVL32rr;
  case X86::CMOVL64rm:
    return X86::CMOVL32rm;
  case X86::CMOVNE64rr:
    return X86::CMOVNE32rr;
  case X86::CMOVNE64rm:
    return X86::CMOVNE32rm;
  case X86::CMOVNO64rr:
    return X86::CMOVNO32rr;
  case X86::CMOVNO64rm:
    return X86::CMOVNO32rm;
  case X86::CMOVNP64rr:
    return X86::CMOVNP32rr;
  case X86::CMOVNP64rm:
    return X86::CMOVNP32rm;
  case X86::CMOVNS64rr:
    return X86::CMOVNS32rr;
  case X86::CMOVNS64rm:
    return X86::CMOVNS32rm;
  case X86::CMOVO64rr:
    return X86::CMOVO32rr;
  case X86::CMOVO64rm:
    return X86::CMOVO32rm;
  case X86::CMOVP64rr:
    return X86::CMOVP32rr;
  case X86::CMOVP64rm:
    return X86::CMOVP32rm;
  case X86::CMOVS64rr:
    return X86::CMOVS32rr;
  case X86::CMOVS64rm:
    return X86::CMOVS32rm;
  case X86::CMP64rr:
    return X86::CMP32rr;
  case X86::CMP64ri8:
    return X86::CMP32ri8;
  case X86::CMP64ri32:
    return X86::CMP32ri;
  case X86::CMP64rm:
    return X86::CMP32rm;
  case X86::CMPXCHG64rr:
    return X86::CMPXCHG32rr;
  case X86::CRC32r64r8:
    return X86::CRC32r32r8;
  case X86::CRC32r64m8:
    return X86::CRC32r64m8;
  case X86::CRC32r64r64:
    return X86::CRC32r32r32;
  case X86::CRC32r64m64:
    return X86::CRC32r32m32;
  case X86::CVTSD2SI64rr:
    return X86::CVTSD2SIrr;
  case X86::CVTSD2SI64rm:
    return X86::CVTSD2SIrm;
  case X86::CVTSS2SI64rr:
    return X86::CVTSS2SIrr;
  case X86::CVTSS2SI64rm:
    return X86::CVTSS2SIrm;
  case X86::CVTTSD2SI64rr:
    return X86::CVTTSD2SIrr;
  case X86::CVTTSD2SI64rm:
    return X86::CVTTSD2SIrm;
  case X86::CVTTSS2SI64rr:
    return X86::CVTTSS2SIrr;
  case X86::CVTTSS2SI64rm:
    return X86::CVTTSS2SIrm;
  case X86::DEC64r:
    return X86::DEC32r;
  case X86::DIV64r:
    return X86::DIV32r;
  case X86::IDIV64r:
    return X86::IDIV32r;
  case X86::IMUL64r:
    return X86::IMUL32r;
  case X86::IMUL64rr:
    return X86::IMUL32rr;
  case X86::IMUL64rri8:
    return X86::IMUL32rri8;
  case X86::IMUL64rri32:
    return X86::IMUL32rri;
  case X86::IMUL64rm:
    return X86::IMUL32rm;
  case X86::IMUL64rmi8:
    return X86::IMUL32rmi8;
  case X86::IMUL64rmi32:
    return X86::IMUL32rmi;
  case X86::INC64r:
    return X86::INC32r;
  case X86::INVEPT64:
    return X86::INVEPT32;
  case X86::INVPCID64:
    return X86::INVPCID32;
  case X86::INVVPID64:
    return X86::INVVPID32;
  case X86::JMP64r:
    return X86::JMP32r;
  case X86::KMOVQrk:
    return X86::KMOVQrk;
  case X86::LAR64rr:
    return X86::LAR32rr;
  case X86::LAR64rm:
    return X86::LAR32rm;
  case X86::LEA64r:
    return X86::LEA32r;
  case X86::LFS64rm:
    return X86::LFS32rm;
  case X86::LGS64rm:
    return X86::LGS32rm;
  case X86::LSL64rr:
    return X86::LSL32rr;
  case X86::LSL64rm:
    return X86::LSL32rm;
  case X86::LSS64rm:
    return X86::LSS32rm;
  case X86::LZCNT64rr:
    return X86::LZCNT32rr;
  case X86::LZCNT64rm:
    return X86::LZCNT32rm;
  case X86::MOV64ri:
    return X86::MOV32ri;
  case X86::MOVBE64rm:
    return X86::MOVBE32rm;
  case X86::MOV64rr:
    return X86::MOV32rr;
  case X86::MMX_MOVD64from64rr:
    return X86::MMX_MOVD64grr;
  case X86::MOVPQIto64rr:
    return X86::MOVPDI2DIrr;
  case X86::MOV64rs:
    return X86::MOV32rs;
  case X86::MOV64rd:
    return X86::MOV32rd;
  case X86::MOV64rc:
    return X86::MOV32rc;
  case X86::MOV64ri32:
    return X86::MOV32ri;
  case X86::MOV64rm:
    return X86::MOV32rm;
  case X86::MOVSX64rr8:
    return X86::MOVSX32rr8;
  case X86::MOVSX64rm8:
    return X86::MOVSX32rm8;
  case X86::MOVSX64rr32:
    return X86::MOV32rr;
  case X86::MOVSX64rm32:
    return X86::MOV32rm;
  case X86::MOVSX64rr16:
    return X86::MOVSX32rr16;
  case X86::MOVSX64rm16:
    return X86::MOVSX32rm16;
  case X86::MOVZX64rr8_Q:
    return X86::MOVZX32rr8;
  case X86::MOVZX64rm8_Q:
    return X86::MOVZX32rm8;
  case X86::MOVZX64rr16_Q:
    return X86::MOVZX32rr16;
  case X86::MOVZX64rm16_Q:
    return X86::MOVZX32rm16;
  case X86::MUL64r:
    return X86::MUL32r;
  case X86::MULX64rr:
    return X86::MULX32rr;
  case X86::MULX64rm:
    return X86::MULX32rm;
  case X86::NEG64r:
    return X86::NEG32r;
  case X86::NOT64r:
    return X86::NOT32r;
  case X86::OR64rr:
    return X86::OR32rr;
  case X86::OR64ri8:
    return X86::OR32ri8;
  case X86::OR64ri32:
    return X86::OR32ri;
  case X86::OR64rm:
    return X86::OR32rm;
  case X86::PDEP64rr:
    return X86::PDEP32rr;
  case X86::PDEP64rm:
    return X86::PDEP32rm;
  case X86::PEXT64rr:
    return X86::PEXT32rr;
  case X86::PEXT64rm:
    return X86::PEXT32rm;
  case X86::PEXTRQrr:
    return X86::PEXTRQrr;
  case X86::POPCNT64rr:
    return X86::POPCNT32rr;
  case X86::POPCNT64rm:
    return X86::POPCNT32rm;
  case X86::POP64r:
    return X86::POP32r;
  case X86::POP64rmr:
    return X86::POP32rmr;
  case X86::PUSH64r:
    return X86::PUSH32r;
  case X86::PUSH64rmr:
    return X86::PUSH32rmr;
  case X86::RCL64r1:
    return X86::RCL32r1;
  case X86::RCL64rCL:
    return X86::RCL32rCL;
  case X86::RCL64ri:
    return X86::RCL32ri;
  case X86::RCR64r1:
    return X86::RCR32r1;
  case X86::RCR64rCL:
    return X86::RCR32rCL;
  case X86::RCR64ri:
    return X86::RCR32ri;
  case X86::RDFSBASE64:
    return X86::RDFSBASE64;
  case X86::RDGSBASE64:
    return X86::RDGSBASE64;
  case X86::RDRAND64r:
    return X86::RDRAND32r;
  case X86::RDSEED64r:
    return X86::RDSEED32r;
  case X86::ROL64r1:
    return X86::ROL32r1;
  case X86::ROL64rCL:
    return X86::ROL32rCL;
  case X86::ROL64ri:
    return X86::ROL32ri;
  case X86::ROR64r1:
    return X86::ROR32r1;
  case X86::ROR64rCL:
    return X86::ROR32rCL;
  case X86::ROR64ri:
    return X86::ROR32ri;
  case X86::RORX64ri:
    return X86::RORX32ri;
  case X86::RORX64mi:
    return X86::RORX64mi;
  case X86::SAR64r1:
    return X86::SAR32r1;
  case X86::SAR64rCL:
    return X86::SAR32rCL;
  case X86::SAR64ri:
    return X86::SAR32ri;
  case X86::SARX64rr:
    return X86::SARX32rr;
  case X86::SARX64rm:
    return X86::SARX32rm;
  case X86::SBB64rr:
    return X86::SBB32rr;
  case X86::SBB64ri8:
    return X86::SBB32ri8;
  case X86::SBB64ri32:
    return X86::SBB32ri;
  case X86::SBB64rm:
    return X86::SBB32rm;
  case X86::SHLD64rrCL:
    return X86::SHLD32rrCL;
  case X86::SHLD64rri8:
    return X86::SHLD32rri8;
  case X86::SHL64r1:
    return X86::SHL32r1;
  case X86::SHL64rCL:
    return X86::SHL32rCL;
  case X86::SHL64ri:
    return X86::SHL32ri;
  case X86::SHLX64rr:
    return X86::SHLX32rr;
  case X86::SHLX64rm:
    return X86::SHLX32rm;
  case X86::SHRD64rrCL:
    return X86::SHRD32rrCL;
  case X86::SHRD64rri8:
    return X86::SHRD32rri8;
  case X86::SHR64r1:
    return X86::SHR32r1;
  case X86::SHR64rCL:
    return X86::SHR32rCL;
  case X86::SHR64ri:
    return X86::SHR32ri;
  case X86::SHRX64rr:
    return X86::SHRX32rr;
  case X86::SHRX64rm:
    return X86::SHRX32rm;
  case X86::SLDT64r:
    return X86::SLDT32r;
  case X86::SMSW64r:
    return X86::SMSW32r;
  case X86::STR64r:
    return X86::STR32r;
  case X86::SUB64rr:
    return X86::SUB32rr;
  case X86::SUB64ri8:
    return X86::SUB32ri8;
  case X86::SUB64ri32:
    return X86::SUB32ri;
  case X86::SUB64rm:
    return X86::SUB32rm;
  case X86::T1MSKC64rr:
    return X86::T1MSKC32rr;
  case X86::T1MSKC64rm:
    return X86::T1MSKC32rm;
  case X86::TEST64rr:
    return X86::TEST32rr;
  case X86::TEST64ri32:
    return X86::TEST32ri;
  case X86::TEST64rm:
    return X86::TEST32rm;
  case X86::TZCNT64rr:
    return X86::TZCNT32rr;
  case X86::TZCNT64rm:
    return X86::TZCNT32rm;
  case X86::TZMSK64rr:
    return X86::TZMSK32rr;
  case X86::TZMSK64rm:
    return X86::TZMSK32rm;
  case X86::VCVTSD2SI64rr:
    return X86::VCVTSD2SIrr;
  case X86::VCVTSD2SI64Zrr:
    return X86::VCVTSD2SIZrr;
  case X86::VCVTSD2SI64Zrm:
    return X86::VCVTSD2SIZrm;
  case X86::VCVTSD2SI64rm:
    return X86::VCVTSD2SIrm;
  case X86::VCVTSD2USI64Zrr:
    return X86::VCVTSD2USIZrr;
  case X86::VCVTSD2USI64Zrm:
    return X86::VCVTSD2USIZrm;
  case X86::VCVTSS2SI64rr:
    return X86::VCVTSS2SIrr;
  case X86::VCVTSS2SI64Zrr:
    return X86::VCVTSS2SIZrr;
  case X86::VCVTSS2SI64Zrm:
    return X86::VCVTSS2SIZrm;
  case X86::VCVTSS2SI64rm:
    return X86::VCVTSS2SIrm;
  case X86::VCVTSS2USI64Zrr:
    return X86::VCVTSS2USIZrr;
  case X86::VCVTSS2USI64Zrm:
    return X86::VCVTSS2USIZrm;
  case X86::VCVTTSD2SI64rr:
    return X86::VCVTTSD2SIrr;
  case X86::VCVTTSD2SI64Zrr:
    return X86::VCVTTSD2SIZrr;
  case X86::VCVTTSD2SI64Zrm:
    return X86::VCVTTSD2SIZrm;
  case X86::VCVTTSD2SI64rm:
    return X86::VCVTTSD2SIrm;
  case X86::VCVTTSD2USI64Zrr:
    return X86::VCVTTSD2USIZrr;
  case X86::VCVTTSD2USI64Zrm:
    return X86::VCVTTSD2USIZrm;
  case X86::VCVTTSS2SI64rr:
    return X86::VCVTTSS2SIrr;
  case X86::VCVTTSS2SI64Zrr:
    return X86::VCVTTSS2SIZrr;
  case X86::VCVTTSS2SI64Zrm:
    return X86::VCVTTSS2SIZrm;
  case X86::VCVTTSS2SI64rm:
    return X86::VCVTTSS2SIrm;
  case X86::VCVTTSS2USI64Zrr:
    return X86::VCVTTSS2USIZrr;
  case X86::VCVTTSS2USI64Zrm:
    return X86::VCVTTSS2USIZrm;
  case X86::VMOVPQIto64rr:
    return X86::VMOVPDI2DIrr;
  case X86::VMOVPQIto64Zrr:
    return X86::VMOVPDI2DIZrr;
  case X86::VMREAD64rr:
    return X86::VMREAD32rr;
  case X86::VMWRITE64rr:
    return X86::VMWRITE32rr;
  case X86::VMWRITE64rm:
    return X86::VMWRITE32rm;
  case X86::VPEXTRQrr:
    return X86::VPEXTRQrr;
  case X86::WRFSBASE64:
    return X86::WRFSBASE;
  case X86::WRGSBASE64:
    return X86::WRGSBASE;
  case X86::XADD64rr:
    return X86::XADD32rr;
  case X86::XCHG64ar:
    return X86::XCHG32ar;
  case X86::XCHG64rr:
    return X86::XCHG32rr;
  case X86::XCHG64rm:
    return X86::XCHG32rm;
  case X86::XOR64ri8:
    return X86::XOR32ri8;
  case X86::XOR64ri32:
    return X86::XOR32ri;
  case X86::XOR64rm:
    return X86::XOR32rm;
  default:
    return Opcode;
  }
}
