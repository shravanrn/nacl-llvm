//===- ARMMCNaClExpander.cpp ------------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the ARMMCNaClExpander class, the ARM specific
// subclass of MCNaClExpander.
//
//===----------------------------------------------------------------------===//
#include "ARMMCNaClExpander.h"
#include "ARMAddressingModes.h"
#include "MCTargetDesc/ARMBaseInfo.h"

#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCInstrDesc.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCNaClExpander.h"
#include "llvm/MC/MCObjectFileInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCStreamer.h"

using namespace llvm;

const unsigned kBranchTargetMask = 0xC000000F;
const unsigned kSandboxMask = 0xC0000000;

bool ARM::ARMMCNaClExpander::isValidScratchRegister(unsigned Reg) const {
  // TODO(dschuff): Also check the regster class.
  return Reg != ARM::PC && Reg != ARM::SP;
}

static void emitBicMask(unsigned Mask, unsigned Reg, ARMCC::CondCodes Pred,
                        unsigned PredReg, MCStreamer &Out,
                        const MCSubtargetInfo &STI) {
  MCInst Bic;
  const int32_t EncodedMask = ARM_AM::getSOImmVal(Mask);
  Bic.setOpcode(ARM::BICri);
  Bic.addOperand(MCOperand::CreateReg(Reg));
  Bic.addOperand(MCOperand::CreateReg(Reg));
  Bic.addOperand(MCOperand::CreateImm(EncodedMask));
  Bic.addOperand(MCOperand::CreateImm(Pred));
  Bic.addOperand(MCOperand::CreateReg(ARM::CPSR));
  Bic.addOperand(MCOperand::CreateReg(0));
  Out.EmitInstruction(Bic, STI);
}

static ARMCC::CondCodes
getPredicate(const MCInst &Inst, const MCInstrInfo &Info, unsigned &PredReg) {
  const MCInstrDesc &Desc = Info.get(Inst.getOpcode());
  int PIdx = Desc.findFirstPredOperandIdx();
  if (PIdx == -1) {
    PredReg = 0;
    return ARMCC::AL;
  }

  PredReg = Inst.getOperand(PIdx + 1).getReg();
  return static_cast<ARMCC::CondCodes>(Inst.getOperand(PIdx).getImm());
}

// return a conditional branch through Reg based on the condition codes of Inst
static MCInst getConditionalBranch(unsigned Reg, const MCInst &Inst,
                                   const MCInstrInfo &II) {
  unsigned PredReg;
  ARMCC::CondCodes Pred = getPredicate(Inst, II, PredReg);

  MCInst BranchInst;
  BranchInst.setOpcode(ARM::BX_pred);
  BranchInst.addOperand(MCOperand::CreateReg(Reg));
  BranchInst.addOperand(MCOperand::CreateImm(Pred));
  BranchInst.addOperand(MCOperand::CreateReg(PredReg));
  return BranchInst;
}

void ARM::ARMMCNaClExpander::expandIndirectBranch(const MCInst &Inst,
                                                  MCStreamer &Out,
                                                  const MCSubtargetInfo &STI,
                                                  bool isCall) {
  assert(Inst.getOperand(0).isReg());
  unsigned BranchReg = Inst.getOperand(0).getReg();

  // No need to sandbox branch through sp or pc
  if (BranchReg == ARM::SP || BranchReg == ARM::PC)
    return Out.EmitInstruction(Inst, STI);

  unsigned PredReg;
  ARMCC::CondCodes Pred = getPredicate(Inst, *InstInfo, PredReg);

  // Otherwise, mask target and branch through
  Out.EmitBundleLock(isCall);
  emitBicMask(kBranchTargetMask, BranchReg, Pred, PredReg, Out, STI);
  Out.EmitInstruction(Inst, STI);
  Out.EmitBundleUnlock();
}

void ARM::ARMMCNaClExpander::expandCall(const MCInst &Inst, MCStreamer &Out,
                                        const MCSubtargetInfo &STI) {
  // Test for indirect call
  if (Inst.getOperand(0).isReg()) {
    expandIndirectBranch(Inst, Out, STI, true);
  }

  // Otherwise, we are a direct call, so just emit
  else {
    Out.EmitInstruction(Inst, STI);
  }
}

void ARM::ARMMCNaClExpander::expandReturn(const MCInst &Inst, MCStreamer &Out,
                                          const MCSubtargetInfo &STI) {
  unsigned Opcode = Inst.getOpcode();
  if (Opcode == ARM::BX_RET || Opcode == ARM::MOVPCLR) {
    MCInst BranchInst = getConditionalBranch(ARM::LR, Inst, *InstInfo);
    return expandIndirectBranch(BranchInst, Out, STI, false);
  }

  return Out.EmitInstruction(Inst, STI);
}

void ARM::ARMMCNaClExpander::expandControlFlow(const MCInst &Inst,
                                               MCStreamer &Out,
                                               const MCSubtargetInfo &STI) {

  // Optimize if we are just moving into PC
  if (Inst.getOpcode() == ARM::MOVr && Inst.getOperand(0).getReg() == ARM::PC) {
    unsigned Src = Inst.getOperand(1).getReg();
    MCInst BranchInst = getConditionalBranch(Src, Inst, *InstInfo);
    return expandIndirectBranch(BranchInst, Out, STI, false);
  }

  if (numScratchRegs() == 0)
    Error(Inst, "Not enough scratch registers provided");

  unsigned Scratch = getScratchReg(0);

  MCInst SandboxedInst(Inst);

  replaceDefinitions(SandboxedInst, ARM::PC, Scratch);
  doExpandInst(SandboxedInst, Out, STI);

  MCInst BranchInst = getConditionalBranch(Scratch, Inst, *InstInfo);
  doExpandInst(BranchInst, Out, STI);
}

bool ARM::ARMMCNaClExpander::mayModifyStack(const MCInst &Inst) {
  // No way to tell where the variable reglist starts, so conservatively
  // check all registers if the instruction is a variadic load like LDM/VLDM
  if (isVariadic(Inst) && mayLoad(Inst)) {
    for (unsigned i = 0, e = Inst.getNumOperands(); i != e; ++i) {
      if (Inst.getOperand(i).isReg() && Inst.getOperand(i).getReg() == ARM::SP)
        return true;
    }
  }
  // Otherwise, check if any definitions are SP
  return mayModifyRegister(Inst, ARM::SP);
}

void ARM::ARMMCNaClExpander::expandStackManipulation(
    const MCInst &Inst, MCStreamer &Out, const MCSubtargetInfo &STI) {

  // Dont sandbox push/pop
  switch (Inst.getOpcode()) {
  case ARM::LDMIA_UPD:
  case ARM::LDMIB_UPD:
  case ARM::LDMDA_UPD:
  case ARM::LDMDB_UPD:
  case ARM::VLDMDIA_UPD:
  case ARM::VLDMDDB_UPD:
  case ARM::VLDMSIA_UPD:
  case ARM::VLDMSDB_UPD: 
  case ARM::STMIA_UPD:
  case ARM::STMIB_UPD:
  case ARM::STMDA_UPD:
  case ARM::STMDB_UPD:
  case ARM::VSTMDIA_UPD:
  case ARM::VSTMDDB_UPD:
  case ARM::VSTMSIA_UPD:
  case ARM::VSTMSDB_UPD:
  case ARM::LDR_PRE_IMM:
  case ARM::STR_PRE_IMM:
    if (Inst.getOperand(0).getReg() == ARM::SP)
      return Out.EmitInstruction(Inst, STI);
    break;
  case ARM::LDR_POST_IMM:
  case ARM::STR_POST_IMM:
    if (Inst.getOperand(1).getReg() == ARM::SP)
      return Out.EmitInstruction(Inst, STI);
    break;
  default:
    break;
  }

  unsigned PredReg;
  ARMCC::CondCodes Pred = getPredicate(Inst, *InstInfo, PredReg);

  Out.EmitBundleLock(false);
  Out.EmitInstruction(Inst, STI);
  emitBicMask(kSandboxMask, ARM::SP, Pred, PredReg, Out, STI);
  Out.EmitBundleUnlock();
}

void ARM::ARMMCNaClExpander::doExpandInst(const MCInst &Inst, MCStreamer &Out,
                                          const MCSubtargetInfo &STI) {
  // This logic is to remain compatible with the existing pseudo instruction
  // expansion code in ARMMCNaCl.cpp
  if (SaveCount == 0) {
    switch (Inst.getOpcode()) {
    case ARM::SFI_NOP_IF_AT_BUNDLE_END:
      SaveCount = 3;
      break;
    case ARM::SFI_DATA_MASK:
      llvm_unreachable(
          "SFI_DATA_MASK found without preceding SFI_NOP_IF_AT_BUNDLE_END");
      break;
    case ARM::SFI_GUARD_CALL:
    case ARM::SFI_GUARD_INDIRECT_CALL:
    case ARM::SFI_GUARD_INDIRECT_JMP:
    case ARM::SFI_GUARD_RETURN:
    case ARM::SFI_GUARD_LOADSTORE:
    case ARM::SFI_GUARD_LOADSTORE_TST:
      SaveCount = 2;
      break;
    case ARM::SFI_GUARD_SP_LOAD:
      SaveCount = 4;
      break;
    default:
      break;
    }
  }

  if (SaveCount == 0) {
    if (isReturn(Inst)) {
      return expandReturn(Inst, Out, STI);
    } else if (isIndirectBranch(Inst)) {
      return expandIndirectBranch(Inst, Out, STI, false);
    } else if (isCall(Inst)) {
      return expandCall(Inst, Out, STI);
    } else if (isBranch(Inst)) {
      return Out.EmitInstruction(Inst, STI);
    } else if (mayAffectControlFlow(Inst)) {
      return expandControlFlow(Inst, Out, STI);
    } else if (mayModifyStack(Inst)) {
      return expandStackManipulation(Inst, Out, STI);
    } else {
      return Out.EmitInstruction(Inst, STI);
    }
  } else {
    SaveCount--;
    Out.EmitInstruction(Inst, STI);
  }
}

bool ARM::ARMMCNaClExpander::expandInst(const MCInst &Inst, MCStreamer &Out,
                                        const MCSubtargetInfo &STI) {
  if (Guard)
    return false;
  Guard = true;

  doExpandInst(Inst, Out, STI);

  Guard = false;
  return true;
}
