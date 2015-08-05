//===- MCNaClExpander.cpp ---------------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the MCNaClExpander class. This is a base
// class that encapsulates the expansion logic for MCInsts, and holds
// state such as available scratch registers.
//
//===----------------------------------------------------------------------===//

#include "llvm/MC/MCNaClExpander.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"

namespace llvm {

void MCNaClExpander::Error(const MCInst &Inst, const char msg[]) {
  Ctx.FatalError(Inst.getLoc(), msg);
}

void MCNaClExpander::pushScratchReg(unsigned Reg) {
  ScratchRegs.push_back(Reg);
}

unsigned MCNaClExpander::popScratchReg() {
  assert(!ScratchRegs.empty() &&
         "Trying to pop an empty scratch register stack");

  unsigned Reg = ScratchRegs.back();
  ScratchRegs.pop_back();
  return Reg;
}

unsigned MCNaClExpander::getScratchReg(int index) {
  int len = numScratchRegs();
  return ScratchRegs[len - index - 1];
}

unsigned MCNaClExpander::numScratchRegs() const { return ScratchRegs.size(); }

bool MCNaClExpander::isPseudo(const MCInst &Inst) const {
  return InstInfo->get(Inst.getOpcode()).isPseudo();
}

bool MCNaClExpander::mayAffectControlFlow(const MCInst &Inst) const {
  return InstInfo->get(Inst.getOpcode()).mayAffectControlFlow(Inst, *RegInfo);
}

bool MCNaClExpander::isCall(const MCInst &Inst) const {
  return InstInfo->get(Inst.getOpcode()).isCall();
}

bool MCNaClExpander::isBranch(const MCInst &Inst) const {
  return InstInfo->get(Inst.getOpcode()).isBranch();
}

bool MCNaClExpander::isIndirectBranch(const MCInst &Inst) const {
  return InstInfo->get(Inst.getOpcode()).isIndirectBranch();
}

bool MCNaClExpander::isReturn(const MCInst &Inst) const {
  return InstInfo->get(Inst.getOpcode()).isReturn();
}

bool MCNaClExpander::mayLoad(const MCInst &Inst) const {
  return InstInfo->get(Inst.getOpcode()).mayLoad();
}

bool MCNaClExpander::mayStore(const MCInst &Inst) const {
  return InstInfo->get(Inst.getOpcode()).mayStore();
}

bool MCNaClExpander::mayModifyRegister(const MCInst &Inst, unsigned Reg) const {
  return InstInfo->get(Inst.getOpcode()).hasDefOfPhysReg(Inst, Reg, *RegInfo);
}

bool MCNaClExpander::explicitlyModifiesRegister(const MCInst &Inst,
                                                unsigned Reg) const {
  const MCInstrDesc &Desc = InstInfo->get(Inst.getOpcode());
  for (int i = 0; i < Desc.NumDefs; ++i) {
    if (Desc.OpInfo[i].OperandType == MCOI::OPERAND_REGISTER &&
        RegInfo->isSubRegisterEq(Reg, Inst.getOperand(i).getReg()))
      return true;
  }
  return false;
}

// Replaces all definitions of RegOld with RegNew in Inst
void MCNaClExpander::replaceDefinitions(MCInst &Inst, unsigned RegOld,
                                        unsigned RegNew) const {
  const MCInstrDesc &Desc = InstInfo->get(Inst.getOpcode());
  for (int i = 0; i < Desc.NumDefs; ++i) {
    MCOperand &Op = Inst.getOperand(i);
    if (Op.isReg() && Op.getReg() == RegOld)
      Op.setReg(RegNew);
  }
}
}
