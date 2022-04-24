import 'dart:typed_data';

import 'document_file_column.dart';
import 'partial_document_file.dart';
import 'saf.dart' as saf;

extension UriDocumentFileUtils on Uri {
  /// {@macro sharedstorage.saf.fromTreeUri}
  Future<DocumentFile?> toDocumentFile() => DocumentFile.fromTreeUri(this);

  /// {@macro sharedstorage.saf.openDocumentFile}
  Future<void> open() => saf.openDocumentFile(this);

  /// {@macro sharedstorage.saf.openDocumentFile}
  Future<void> openDocumentFile() => open();
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

  /// {@macro sharedstorage.saf.fromTreeUri}
  static Future<DocumentFile?> fromTreeUri(Uri uri) => saf.fromTreeUri(uri);

  /// {@macro sharedstorage.saf.child}
  Future<DocumentFile?> child(
    String path, {
    bool requiresWriteAccess = false,
  }) =>
      saf.child(uri, path, requiresWriteAccess: requiresWriteAccess);

  /// {@macro sharedstorage.saf.openDocumentFile}
  Future<bool?> openDocumentFile() => saf.openDocumentFile(uri);

  /// {@macro sharedstorage.saf.openDocumentFile}
  ///
  /// Alias/shortname for [openDocumentFile]
  Future<bool?> open() => openDocumentFile();

  /// {@macro sharedstorage.saf.canWrite}
  Future<bool?> canRead() async => saf.canWrite(uri);

  /// {@macro sharedstorage.saf.canWrite}
  Future<bool?> canWrite() async => saf.canWrite(uri);

  /// {@macro sharedstorage.saf.listFiles}
  Stream<PartialDocumentFile> listFiles(List<DocumentFileColumn> columns) =>
      saf.listFiles(uri, columns: columns);

  /// {@macro sharedstorage.saf.exists}
  Future<bool?> exists() => saf.exists(uri);

  /// {@macro sharedstorage.saf.delete}
  Future<bool?> delete() => saf.delete(uri);

  /// {@macro sharedstorage.saf.copy}
  Future<DocumentFile?> copy(Uri destination) => saf.copy(uri, destination);

  /// {@macro sharedstorage.saf.getDocumentContent}
  Future<Uint8List?> getContent(Uri destination) => saf.getDocumentContent(uri);

  /// {@macro sharedstorage.saf.getContentAsString}
  Future<String?> getContentAsString(Uri destination) =>
      saf.getDocumentContentAsString(uri);

  /// {@macro sharedstorage.saf.createDirectory}
  Future<DocumentFile?> createDirectory(String displayName) =>
      saf.createDirectory(uri, displayName);

  /// {@macro sharedstorage.saf.createFileAsBytes}
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

  /// {@macro sharedstorage.saf.createFile}
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

  /// Alias for [createFile] with [content] param
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

  /// {@macro sharedstorage.saf.length}
  Future<int?> get length => saf.documentLength(uri);

  /// {@macro sharedstorage.saf.lastModified}
  Future<DateTime?> get lastModified => saf.lastModified(uri);

  /// {@macro sharedstorage.saf.findFile}
  Future<DocumentFile?> findFile(String displayName) =>
      saf.findFile(uri, displayName);

  /// {@macro sharedstorage.saf.renameTo}
  Future<DocumentFile?> renameTo(String displayName) =>
      saf.renameTo(uri, displayName);

  /// {@macro sharedstorage.saf.parentFile}
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
