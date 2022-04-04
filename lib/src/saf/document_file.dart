import 'dart:typed_data';

import '../../saf.dart';
import 'saf.dart' as saf;

extension UriDocumentFileUtils on Uri {
  /// Same as `DocumentFile.fromTreeUri(this)`
  Future<DocumentFile?> toDocumentFile() => DocumentFile.fromTreeUri(this);
}

/// Equivalent to Android `DocumentFile` class
///
/// [Refer to details](https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile)
class DocumentFile {
  const DocumentFile({
    required this.name,
    required this.type,
    required this.uri,
    required this.isDirectory,
    required this.isFile,
    required this.isVirtual,
  });

  factory DocumentFile.fromMap(Map<String, dynamic> map) {
    return DocumentFile(
      isDirectory: map['isDirectory'] as bool,
      isFile: map['isFile'] as bool,
      isVirtual: map['isVirtual'] as bool,
      name: map['name'] as String,
      type: map['type'] as String?,
      uri: Uri.parse(map['uri'] as String),
    );
  }

  /// Display name of this document file, useful to show as a title in a list of files
  final String name;

  /// Mimetype of this document file, useful to determine how to display it
  final String? type;

  /// Path, URI, location of this document, it can exists or not
  final Uri uri;

  /// Whether this document is a directory or not
  final bool isDirectory;

  /// Whether this document is a file or not
  final bool isFile;

  /// Whether this document is a virtual file or not
  final bool isVirtual;

  /// Same as `uri.toDocumentFile` where `uri` is of type `Uri`
  static Future<DocumentFile?> fromTreeUri(Uri uri) => saf.fromTreeUri(uri);

  /// Same as `canRead`
  Future<bool?> canRead() async => saf.canWrite(uri);

  /// Same as `canWrite`
  Future<bool?> canWrite() async => saf.canWrite(uri);

  /// Same as `listFiles`
  Stream<PartialDocumentFile> listFiles(List<DocumentFileColumn> columns) =>
      saf.listFiles(uri, columns: columns);

  /// Same as `exists`
  Future<bool?> exists() => saf.exists(uri);

  /// Same as `delete`
  Future<bool?> delete() => saf.delete(uri);

  /// Same as `copy`
  Future<DocumentFile?> copy(Uri destination) => saf.copy(uri, destination);

  /// Same as `getDocumentContent`
  Future<Uint8List?> getContent(Uri destination) => saf.getDocumentContent(uri);

  /// Same as `getDocumentContentAsString`
  Future<String?> getContentAsString(Uri destination) =>
      saf.getDocumentContentAsString(uri);

  /// Same as `createDirectory`
  Future<DocumentFile?> createDirectory(String displayName) =>
      saf.createDirectory(uri, displayName);

  /// Same as `createFileAsBytes`
  ///
  /// Create a direct child document of `this` document
  Future<DocumentFile?> createFileAsBytes({
    required String mimeType,
    required String displayName,
    required Uint8List bytes,
  }) =>
      saf.createFile(
        uri,
        mimeType: mimeType,
        displayName: displayName,
        bytes: bytes,
      );

  /// Same as `createFile`
  ///
  /// Create a direct child document of `this` document
  Future<DocumentFile?> createFile({
    required String mimeType,
    required String displayName,
    String? content,
    Uint8List? bytes,
  }) =>
      saf.createFile(
        uri,
        mimeType: mimeType,
        displayName: displayName,
        content: content,
        bytes: bytes,
      );

  /// Same as `createFileAsString`
  ///
  /// Create a direct child document of `this` document
  Future<DocumentFile?> createFileAsString({
    required String mimeType,
    required String displayName,
    required String content,
  }) =>
      saf.createFile(
        uri,
        mimeType: mimeType,
        displayName: displayName,
        content: content,
      );

  /// Same as `documentLength`
  Future<int?> get length => saf.documentLength(uri);

  /// Same as `lastModified`
  Future<DateTime?> get lastModified => saf.lastModified(uri);

  /// Same as `findFile`
  Future<DocumentFile?> findFile(String displayName) =>
      saf.findFile(uri, displayName);

  /// Same as `renameTo`
  Future<DocumentFile?> renameTo(String displayName) =>
      saf.renameTo(uri, displayName);

  /// Same as `parentFile`
  Future<DocumentFile?> parentFile() => saf.parentFile(uri);

  Map<String, dynamic> toMap() {
    return {
      'isDirectory': isDirectory,
      'isFile': isFile,
      'isVirtual': isVirtual,
      'name': name,
      'type': type,
      'uri': '$uri',
    };
  }

  @override
  bool operator ==(Object other) {
    if (other is! DocumentFile) return false;

    return isDirectory == other.isDirectory &&
        isFile == other.isFile &&
        isVirtual == other.isVirtual &&
        name == other.name &&
        type == other.type &&
        uri == other.uri;
  }

  @override
  int get hashCode =>
      Object.hash(isDirectory, isFile, isVirtual, name, type, uri);
}
