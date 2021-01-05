import 'dart:ffi';
import 'dart:io' show Platform;

import 'miniaudio-c.dart';

// let files importing bindings.dart also get all the OBX_* types
export 'miniaudio-c.dart';

MiniAudioC loadMiniAudioLib() {
  DynamicLibrary /*?*/ lib;
  var libName = 'miniaudio';
  if (Platform.isWindows) {
    libName += '.dll';
  } else if (Platform.isMacOS) {
    libName = 'lib$libName.dylib';
  } else if (Platform.isIOS) {
    // this works in combination with `'OTHER_LDFLAGS' => '-framework MiniAudio'` in miniaudio_flutter_libs.podspec
    lib = DynamicLibrary.process();
    // alternatively, if `DynamicLibrary.process()` wasn't faster (it should be though...)
    // libName = 'MiniAudio.framework/MiniAudio';
  } else if (Platform.isAndroid) {
    libName = 'lib$libName.so';
  } else if (Platform.isLinux) {
    libName = 'lib$libName.so';
  } else {
    throw Exception(
        'unsupported platform detected: ${Platform.operatingSystem}');
  }
  lib ??= DynamicLibrary.open(libName);
  return MiniAudioC(lib);
}

MiniAudioC /*?*/ _cachedBindings;

MiniAudioC get bindings => _cachedBindings ??= loadMiniAudioLib();
