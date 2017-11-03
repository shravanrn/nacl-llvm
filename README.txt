This has further been modified to ensure the LLVM-NACL does not break ABI compatibility with non NACL binaries when compiling for NACL
The clang front end that accompanies this is located here https://github.com/shravanrn/nacl-clang.git

Build both LLVM and Clang by following instructions from the below link but using the nacl-llvm.git and nacl-clang.git repos
https://clang.llvm.org/get_started.html

Some useful commands during development - Point the produces compiler to the correct folders for libc, the nacl assembler etc.

export LIBRARY_PATH=/home/shr/Code/nacl2/native_client/toolchain/linux_x86/nacl_x86_newlib/x86_64-nacl/lib/:/home/shr/Code/nacl2/native_client/toolchain/linux_x86/nacl_x86_newlib/lib/gcc/x86_64-nacl/4.4.3/:$LIBRARY_PATH

export COMPILER_PATH=/home/shr/Code/nacl2/native_client/toolchain/linux_x86/pnacl_newlib/bin/:/home/shr/Code/nacl2/native_client/toolchain/linux_x86/nacl_x86_newlib/x86_64-nacl/lib/:/home/shr/Code/nacl2/native_client/toolchain/linux_x86/nacl_x86_newlib/lib/gcc/x86_64-nacl/4.4.3/:$COMPILER_PATH

/home/shr/Code/pnacl_llvm_build/bin/clang -target "x86_64-nacl" -o ~/Desktop/naclbuild/testc_custom_64_newtest ~/Desktop/naclbuild/testc.c


NACL-LLVM
==========
This is the modified LLVM that supports the NACL backend.

Low Level Virtual Machine (LLVM)
================================

This directory and its subdirectories contain source code for LLVM,
a toolkit for the construction of highly optimized compilers,
optimizers, and runtime environments.

LLVM is open source software. You may freely distribute it under the terms of
the license agreement found in LICENSE.txt.

Please see the documentation provided in docs/ for further
assistance with LLVM, and in particular docs/GettingStarted.rst for getting
started with LLVM and docs/README.txt for an overview of LLVM's
documentation setup.

If you're writing a package for LLVM, see docs/Packaging.rst for our
suggestions.
