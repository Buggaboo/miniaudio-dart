import 'dart:ffi';
import 'dart:convert';
import 'dart:io';
import 'dart:convert';
import 'package:ffi/ffi.dart';

import '../lib/src/bindings/bindings.dart';
import '../lib/src/bindings/miniaudio-c.dart';
import 'package:test/test.dart';

MiniAudioC b;

void main() {
  group('A playback test group', () {


    setUp(() {
      b = bindings;
    });

    test('play wav', () {
      final filenames = ['dummy', 'media/taunt.wav'];
      Pointer<Pointer<Int8>> argv = allocate(count: 2);
      final utf8s = filenames.map(Utf8.toUtf8).toList();
      [0,1].forEach((i) => argv[i] = utf8s[i].cast<Int8>());
      final result = b.single_playback(2, argv);
      expect(result, 0);
      free(argv);
    });
  });
}
