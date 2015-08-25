//===- llvm/unittests/Bitcode/NaClMungeTest.cpp - Test munging utils ------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Implements stringify methods for munging tests.
//
//===----------------------------------------------------------------------===//

#include "NaClMungeTest.h"
#include <regex>

using namespace llvm;

namespace naclmungetest {

static bool matchErrorPrefixForLine(const std::string &Line, std::regex &Exp,
                                    std::string &Suffix) {
  std::smatch Match;
  if (std::regex_search(Line, Match, Exp)) {
    // Note: Element 0 is the original string.
    Suffix = Match[2];
    return true;
  }
  Suffix.clear();
  return false;
}

static std::string stripErrorPrefixForLine(const std::string &Line) {
  std::string Suffix;
  std::regex ErrorExp("[Ee]rror: (\\(.*\\) )?(.*)");
  if (matchErrorPrefixForLine(Line, ErrorExp, Suffix))
    return Suffix;
  std::regex WarningExp("[Ww]arning: (\\(.*\\) )?(.*)");
  if (matchErrorPrefixForLine(Line, WarningExp, Suffix))
    return Suffix;
  return Line;
}

std::string stripErrorPrefix(const std::string &Message) {
  std::string Result;
  size_t StartPos = 0;
  size_t NextEoln = Message.find('\n', StartPos);
  while (NextEoln != std::string::npos) {
    std::string Line(Message.c_str() + StartPos, NextEoln - StartPos);
    Result.append(stripErrorPrefixForLine(Line)).push_back('\n');
    StartPos = NextEoln + 1;
    NextEoln = Message.find_first_of("\n", StartPos);
  }
  if (StartPos < Message.size()) {
    std::string Remainder(Message.c_str() + StartPos,
                          Message.size() - StartPos);
    Result.append(stripErrorPrefixForLine(Remainder));
  }
  return Result;
}

} // end of naclmungetest namespace
