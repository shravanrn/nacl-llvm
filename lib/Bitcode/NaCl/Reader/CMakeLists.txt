add_llvm_library(LLVMNaClBitReader
  NaClBitCodes.cpp
  NaClBitcodeHeader.cpp
  NaClBitcodeReader.cpp
  NaClBitstreamReader.cpp
  NaClBitcodeParser.cpp
  NaClBitcodeDecoders.cpp
  )

add_dependencies(LLVMNaClBitReader LLVMBitReader intrinsics_gen)
