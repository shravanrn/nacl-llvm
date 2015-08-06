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

void ARM::ARMMCNaClExpander::expandIndirectBranch(const MCInst &Inst,
                                                  MCStreamer &Out,
                                                  const MCSubtargetInfo &STI,
                                                  bool isCall) {
  assert(Inst.getOperand(0).isReg());
  unsigned BranchReg = Inst.getOperand(0).getReg();
  // No need to sandbox branch through pc
  if (BranchReg == ARM::PC || BranchReg == ARM::SP)
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
    if (isIndirectBranch(Inst)) {
      return expandIndirectBranch(Inst, Out, STI, false);
    } else if (isCall(Inst)) {
      return expandCall(Inst, Out, STI);
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
