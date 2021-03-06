An audio library for Flutter.

This project is based on [miniaudio](https://github.com/mackron/miniaudio) and
made available to flutter via ffi.

Made available under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

## Usage

Generated C bindings with ffigen. `pub get ; pub run ffigen`

Run `*.sh` files first to compile miniaudio for different platforms;
the examples (e.g. android, iOS) rely on those to build the C library.

## Dependencies
* [miniaudio](https://github.com/mackron/miniaudio) (git clone)
* [ios-cmake](https://github.com/leetal/ios-cmake) (git clone)
* LLVM (brew, apt, chocolate)
* Android NDK

## TODO
* Provide instructions to build for iOS, android

## Planned support
* Windows
* WASM
