set(LLVM_LINK_COMPONENTS
  BitReader
  Core
  NaClBitWriter
  NaClBitReader
  Support)

add_llvm_tool(pnacl-addnames
  pnacl-addnames.cpp
  )
