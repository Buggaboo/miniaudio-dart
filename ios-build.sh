#!/bin/sh

# Inspired by [Cross compiling for iOS...](https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html#cross-compiling-for-ios-tvos-or-watchos)

cmake -GXcode \
    -DCMAKE_TOOLCHAIN_FILE=../ios-cmake/ios.toolchain.cmake \
    -DPLATFORM=OS64COMBINED \
    -DCMAKE_C_COMPILER=`which clang` \
    -B build/iOS \
    .

# cmake --build build/iOS

