import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
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
    /// `/storage/emulated/0`
    topLevelSharedDirectory = await getExternalStoragePublicDirectory(
        const EnvironmentDirectory.custom('CustomExternalStorageFolder'));

    /// If you want to write on the shared storage path, remember to
    /// add [permission_handler] package
    await Permission.storage.request();

    if (topLevelSharedDirectory != null) {
      /// Remember to add `android:requestLegacyExternalStorage="true"`
      /// to your Android manifest, otherwise this write request will fail
      await Directory(topLevelSharedDirectory!.absolute.path)
          .create(recursive: true);
    }

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
