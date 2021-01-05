import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:miniaudio_dart/miniaudio.dart' as ma;

import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ma.MiniAudioC bindings;
  int _result = 0;
  List<String> assets;
  Directory dir;

  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then((d) async {
      final assetManifestJsonString =
          await rootBundle.loadString('AssetManifest.json');

      final decoded = jsonDecode(assetManifestJsonString);
      assets = decoded.values.fold([], (x, y) => x + y).cast<String>();

      dir = d;

      bindings = ma.bindings;
      setState(() {});
    });
  }

  Future<void> _player(String path) async {
    String cachePath = '${dir.path}/$path';

    // on demand copy
    if (!FileSystemEntity.isFileSync(cachePath)) {
      ByteData data = await rootBundle.load(path);
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(cachePath).create(recursive: true).then((file) {
        file.writeAsBytes(bytes);
      });
    }

    final filenames = ['dummy', cachePath];
    Pointer<Pointer<Int8>> argv = allocate(count: 2);
    final utf8s = filenames.map(Utf8.toUtf8).toList();
    [0, 1].forEach((i) => argv[i] = utf8s[i].cast<Int8>());
    final result = bindings.single_playback(2, argv);
    free(argv);

    setState(() {
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('result: $_result'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) => ListTile(
            title: Text(
              assets[index],
            ),
            onTap: () => _player(assets[index])),
        itemCount: assets != null ? assets.length : 0,
      ),
    );
  }
}
