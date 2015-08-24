//===- ARMMCNaClExpander.h --------------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the ARMMCNaClExpander class, the ARM specific
// subclass of MCNaClExpander.
//
//===----------------------------------------------------------------------===//
#ifndef LLVM_MC_ARMMCNACLEXPANDER_H
#define LLVM_MC_ARMMCNACLEXPANDER_H

#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCNaClExpander.h"
#include "llvm/MC/MCRegisterInfo.h"

namespace llvm {
class MCContext;
class MCInst;
class MCStreamer;
class MCSubtargetInfo;

namespace ARM {
class ARMMCNaClExpander : public MCNaClExpander {
public:
  ARMMCNaClExpander(const MCContext &Ctx, std::unique_ptr<MCRegisterInfo> &&RI,
                    std::unique_ptr<MCInstrInfo> &&II)
      : MCNaClExpander(Ctx, std::move(RI), std::move(II)) {}

  bool expandInst(const MCInst &Inst, MCStreamer &Out,
                  const MCSubtargetInfo &STI) override;

protected:
  bool isValidScratchRegister(unsigned Reg) const override;

private:
  bool Guard = false; // recursion guard
  int SaveCount = 0;

  void expandIndirectBranch(const MCInst &Inst, MCStreamer &Out,
                            const MCSubtargetInfo &STI, bool isCall);

  void expandCall(const MCInst &Inst, MCStreamer &Out,
                  const MCSubtargetInfo &STI);

  void expandReturn(const MCInst &Inst, MCStreamer &Out,
                    const MCSubtargetInfo &STI);

  bool mayModifyStack(const MCInst &Inst);

  void expandControlFlow(const MCInst &Inst, MCStreamer &Out,
                         const MCSubtargetInfo &STI);

  void expandStackManipulation(const MCInst &Inst, MCStreamer &Out,
                               const MCSubtargetInfo &STI);

  void expandPrefetch(const MCInst &Inst, MCStreamer &Out,
		      const MCSubtargetInfo &STI);

  void expandLoadStore(const MCInst &Inst, MCStreamer &Out,
                       const MCSubtargetInfo &STI);

  void doExpandInst(const MCInst &Inst, MCStreamer &Out,
                    const MCSubtargetInfo &STI);
};
}
}
#endif
