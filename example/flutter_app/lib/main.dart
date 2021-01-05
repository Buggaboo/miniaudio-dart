import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:miniaudio_dart/miniaudio.dart' as ma;

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
  List<FileSystemEntity> paths;
  String backPath;

  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then((dir) async {
      paths = await dir.list(recursive: true).toList();
      backPath = FileSystemEntity.parentOf(dir.path);
      bindings = ma.bindings;
      setState(() {});
    });
  }

  Future<void> _player(String path) async {
    final fileType = FileSystemEntity.typeSync(path);
    if (fileType == FileSystemEntityType.file) {
      final filenames = ['dummy', path];
      Pointer<Pointer<Int8>> argv = allocate(count: 2);
      final utf8s = filenames.map(Utf8.toUtf8).toList();
      [0, 1].forEach((i) => argv[i] = utf8s[i].cast<Int8>());
      final result = bindings.single_playback(2, argv);
      free(argv);

      setState(() {
        _result = result;
      });
    } else if (fileType == FileSystemEntityType.directory) {
      paths = await Directory(path).list(recursive: true).toList();
      backPath = FileSystemEntity.parentOf(path);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('result: $_result'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back), onPressed: () => _player(backPath)),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) => ListTile(
            title: Text(
              paths[index].path,
              style: FileSystemEntity.typeSync(paths[index].path) ==
                      FileSystemEntityType.directory
                  ? TextStyle(fontWeight: FontWeight.bold)
                  : TextStyle(color: Colors.grey),
            ),
            onTap: () => _player(paths[index].path)),
        itemCount: paths != null ? paths.length : 0,
      ),
    );
  }
}
