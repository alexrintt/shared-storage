import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';

import '../../../shared_storage.dart';
import '../../channels.dart';

abstract class ScopedDirectory implements ScopedFileSystemEntity {
  static Future<ScopedDirectory> fromUri(Uri uri) =>
      _ScopedDirectory.fromUri(uri);

  static ScopedDirectory fromMap(Map<String, dynamic> map) {
    return _ScopedDirectory.fromMap(map);
  }

  static Future<ScopedDirectory> fromDirectory(Directory directory) =>
      _ScopedDirectory.fromDirectory(directory);

  /// Create a child entry with the given `displayName` and `mimeType` using the directory reference.
  ///
  /// Scoped storage doesn't support "concatenating" paths.
  Future<ScopedDirectory> createChildDirectory({required String displayName});

  Future<ScopedFile> createChildFile({
    required String displayName,
    required String mimeType,
  });

  Future<ScopedFileSystemEntity?> child(String displayName);

  @override
  Future<ScopedDirectory> rename(String newPath);

  Stream<ScopedFileSystemEntity> list({
    bool recursive = false,
    bool followLinks = false,
  });

  ScopedDirectory renameSync(String newPath);
}

class _ScopedDirectory implements ScopedDirectory {
  const _ScopedDirectory({
    required this.displayName,
    required this.id,
    required this.uri,
    required this.parentUri,
    required this.lastModified,
  });

  @override
  final DateTime lastModified;

  static ScopedDirectory fromMap(Map<String, dynamic> map) {
    return _ScopedDirectory(
      displayName: map['displayName'] as String,
      id: map['id'] as String,
      uri: Uri.parse(map['uri'] as String),
      parentUri: map['parentUri'] != null
          // If it's not a String, it's better to throw TypeError
          ? Uri.parse(map['parentUri'] as String)
          : null,
      lastModified: DateTime.fromMillisecondsSinceEpoch(
        map['lastModified'] as int,
      ),
    );
  }

  @override
  final String displayName;

  @override
  final String id;

  @override
  final Uri uri;

  @override
  final Uri? parentUri;

  static Future<ScopedDirectory> fromUri(Uri uri) async {
    if (uri.scheme == 'file') {
      assert(uri.toString().endsWith('/'));

      final Directory directory = Directory.fromUri(uri);

      if (!directory.existsSync()) {
        throw SharedStorageFileNotFoundException(
          '${directory.path} does not exist. It either means the file actually does not exist or maybe you do not have permission to read it.',
          StackTrace.current,
        );
      }

      final FileStat stat = directory.statSync();

      return _ScopedDirectory(
        displayName: basename(directory.path),
        id: directory.path,
        uri: uri,
        lastModified: stat.modified,
        parentUri: (() {
          try {
            return directory.parent.uri;
          } on Exception {
            return null;
          }
        })(),
      );
    } else {
      final Map<String, dynamic>? response =
          await kMediaStoreChannel.invokeMapMethod<String, dynamic>(
        'getScopedFileSystemEntityFromUri',
        <String, dynamic>{
          'uri': uri.toString(),
        },
      );

      return _ScopedDirectory.fromMap(response!);
    }
  }

  static Future<ScopedDirectory> fromDirectory(Directory directory) async {
    return _ScopedDirectory.fromUri(Uri.directory(directory.path));
  }

  @override
  Future<ScopedDirectory> delete({bool recursive = false}) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<bool> exists() {
    // TODO: implement exists
    throw UnimplementedError();
  }

  @override
  Stream<ScopedFileSystemEntity> list({
    bool recursive = false,
    bool followLinks = true,
  }) {
    final Map<String, dynamic> args = <String, dynamic>{
      'uri': '$uri',
      'event': 'listFiles',
    };

    final Stream<dynamic> onCursorRowResult =
        kDocumentFileEventChannel.receiveBroadcastStream(args);

    ScopedFileSystemEntity mapCursorRowToScopedFileSystemEntity(
      Map<String, dynamic> e,
    ) {
      switch (e['entityType']) {
        case 'file':
          return ScopedFile.fromMap(e);
        case 'directory':
          return ScopedDirectory.fromMap(e);
        default:
          throw ArgumentError('Unknown entity type: ${e['entityType']}.');
      }
    }

    Map<String, dynamic> castDynamicMapType(dynamic event) =>
        Map<String, dynamic>.from(event as Map<dynamic, dynamic>);

    return onCursorRowResult
        .map(castDynamicMapType)
        .cast<Map<String, dynamic>>()
        .map(mapCursorRowToScopedFileSystemEntity);
  }

  @override
  Future<ScopedDirectory> rename(String newPath) {
    // TODO: implement rename
    throw UnimplementedError();
  }

  @override
  ScopedDirectory renameSync(String newPath) {
    // TODO: implement renameSync
    throw UnimplementedError();
  }

  @override
  Future<ScopedDirectory> createChildDirectory({required String displayName}) {
    // TODO: implement createChildScopedDirectory
    throw UnimplementedError();
  }

  @override
  Future<ScopedFile> createChildFile({
    required String displayName,
    required String mimeType,
  }) {
    // TODO: implement createChildScopedFile
    throw UnimplementedError();
  }

  @override
  Future<ScopedFileSystemEntity?> child(String displayName) {
    // TODO: implement child
    throw UnimplementedError();
  }

  @override
  FutureOr<ScopedFileSystemEntity> copyTo(
    Uri destination, {
    bool recursive = false,
  }) {
    // TODO: implement copyTo
    throw UnimplementedError();
  }

  @override
  FutureOr<bool> canRead() {
    return kDocumentFileChannel.invokeMethod<bool>(
      'canRead',
      <String, String>{'uri': '$uri'},
    ).then((bool? value) => value ?? false);
  }

  @override
  FutureOr<bool> canWrite() {
    // TODO: implement canWrite
    throw UnimplementedError();
  }
}
