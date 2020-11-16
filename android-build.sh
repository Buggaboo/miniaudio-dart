#!/bin/sh

# Inspired by [BoringSSL build instructions](https://boringssl.googlesource.com/boringssl/+/2987/third_party/android-cmake/README.md)

BUILD_TYPE=${BUILD_TYPE:=Debug} # or Release

for abi in armeabi-v7a arm64-v8a x86_64; do
  cmake -DCMAKE_TOOLCHAIN_FILE=$(find $ANDROID_NDK -name android.toolchain.cmake) \
      -DANDROID_NDK=$ANDROID_NDK     \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DANDROID_ABI=$abi       \
      -B build/android/$abi \
      .

  cmake --build build/android/$abi
done