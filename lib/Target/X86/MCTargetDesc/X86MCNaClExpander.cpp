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
    // Don't handle stack manipulations for now
    emitInstruction(Inst, Out, STI, EmitPrefixes);
  } else if (Is64Bit && explicitlyModifiesRegister(Inst, X86::RBP)) {
    emitInstruction(Inst, Out, STI, EmitPrefixes);
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
