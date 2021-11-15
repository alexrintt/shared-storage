import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_storage/shared_storage.dart';

void main() => runApp(const App());

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  Directory? topLevelSharedDirectory;

  String? get _absolutePath => topLevelSharedDirectory?.absolute.path;

  @override
  void initState() {
    super.initState();

    _getPublicDirectoryPath();
  }

  Future<void> _getPublicDirectoryPath() async {
    /// [/storage/emulated/0/Download]
    topLevelSharedDirectory =
        await getExternalStoragePublicDirectory(EnvironmentDirectory.downloads);

    setState(() => {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SharedStorage Sample'),
        ),
        body: Center(
          child: Text(_absolutePath ?? 'Loading...'),
        ),
      ),
    );
  }
}
