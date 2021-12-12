import 'package:shared_storage/src/channels.dart';
import 'package:shared_storage/src/storage_access_framework/document_file_column.dart';

extension UriDocumentFileUtils on Uri {
  Future<DocumentFile?> toDocumentFile() => DocumentFile.fromTreeUri(this);
}

class DocumentFile {
  final String name;
  final String? type;
  final Uri uri;
  final bool isDirectory;
  final bool isFile;
  final bool isVirtual;

  const DocumentFile(
      {required this.name,
      required this.type,
      required this.uri,
      required this.isDirectory,
      required this.isFile,
      required this.isVirtual});

  static Future<DocumentFile?> fromTreeUri(Uri uri) async {
    const kFromTreeUri = 'fromTreeUri';

    const kUri = 'uri';

    final documentFile = await kDocumentFileChannel
        .invokeMapMethod<String, dynamic>(kFromTreeUri, {kUri: '$uri'});

    if (documentFile == null) return null;

    return DocumentFile.fromMap(documentFile);
  }

  Map<String, String> get uriArgs => <String, String>{'uri': '$uri'};

  Future<bool?> canRead() async {
    const kCanRead = 'canRead';

    return await kDocumentFileChannel
        .invokeMethod<bool>(kCanRead, {...uriArgs});
  }

  Future<bool?> canWrite() async {
    const kCanWrite = 'canWrite';

    return await kDocumentFileChannel
        .invokeMethod<bool>(kCanWrite, {...uriArgs});
  }

  /// List document files of a given [uri]
  ///
  /// Note that the [uri] must be a `URI` returned by [openDocumentTree] method
  Future<List<DocumentFile>?> listFiles() async {
    const kListFiles = 'listFiles';

    const kUri = 'uri';

    final args = <String, String>{
      kUri: '$uri',
    };

    final files = await kDocumentFileChannel.invokeListMethod(kListFiles, args);

    if (files == null) return null;

    return files.map((e) => DocumentFile.fromMap(Map.from(e))).toList();
  }

  /// Emits a new event instead returning a single List as `listFiles`
  ///
  /// Great for large data file sets
  Stream<Map<DocumentFileColumn, dynamic>> listFilesAsStream(
      List<DocumentFileColumn> columns) {
    const kListFilesAsStream = 'listFilesAsStream';

    const kUri = 'uri';
    const kEvent = 'event';
    const kColumns = 'columns';

    final args = <String, dynamic>{
      kUri: '$uri',
      kEvent: kListFilesAsStream,
      kColumns: columns.map((e) => '$e').toList(),
    };

    final onCursorRowResult =
        kDocumentFileEventChannel.receiveBroadcastStream(args);

    Map<DocumentFileColumn, dynamic> mapper(e) {
      final mappedColumns = <DocumentFileColumn, dynamic>{
        for (final value in DocumentFileColumn.values)
          if (e['$value'] != null) value: e['$value']
      };

      return mappedColumns;
    }

    return onCursorRowResult
        .map(mapper)
        .cast<Map<DocumentFileColumn, dynamic>>();
  }

  Future<bool?> exists() async {
    const kExists = 'exists';

    return await kDocumentFileChannel.invokeMethod<bool>(kExists, {...uriArgs});
  }

  /// Returns true if deleted successfully
  Future<bool?> delete() async {
    const kDelete = 'delete';

    return await kDocumentFileChannel.invokeMethod<bool>(kDelete, {...uriArgs});
  }

  Future<DocumentFile?> createDirectory(String displayName) async {
    const kCreateDirectory = 'createDirectory';

    const kDisplayNameArg = 'displayName';

    final args = <String, String>{
      ...uriArgs,
      kDisplayNameArg: displayName,
    };

    final createdDocumentFile = await kDocumentFileChannel
        .invokeMapMethod<String, dynamic>(kCreateDirectory, args);

    if (createdDocumentFile == null) return null;

    return DocumentFile.fromMap(createdDocumentFile);
  }

  Future<DocumentFile?> createFile(
      {required String mimeType,
      required String displayName,
      required String content}) async {
    const kCreateFile = 'createFile';

    const kMimeTypeArg = 'mimeType';
    const kContentArg = 'content';
    const kDisplayNameArg = 'displayName';
    const kDirectoryUriArg = 'directoryUri';

    final directoryUri = '$uri';

    final args = <String, String>{
      kMimeTypeArg: mimeType,
      kContentArg: content,
      kDisplayNameArg: displayName,
      kDirectoryUriArg: directoryUri,
    };

    final createdDocumentFile = await kDocumentFileChannel
        .invokeMapMethod<String, dynamic>(kCreateFile, args);

    if (createdDocumentFile == null) return null;

    return DocumentFile.fromMap(createdDocumentFile);
  }

  /// Length in bytes of [this] `DocumentFile`
  Future<int?> get length async {
    const kLength = 'length';

    final length =
        await kDocumentFileChannel.invokeMethod<int>(kLength, {...uriArgs});

    return length;
  }

  Future<DateTime?> get lastModified async {
    const kLastModified = 'lastModified';

    final inMillisecondsSinceEpoch = await kDocumentFileChannel
        .invokeMethod<int>(kLastModified, {...uriArgs});

    if (inMillisecondsSinceEpoch == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(inMillisecondsSinceEpoch);
  }

  Future<DocumentFile?> findFile(String displayName) async {
    const kFindFile = 'findFile';

    const kDisplayNameArg = 'displayName';

    final args = <String, String>{
      ...uriArgs,
      kDisplayNameArg: displayName,
    };

    final matchedDocumentFile = await kDocumentFileChannel
        .invokeMapMethod<String, dynamic>(kFindFile, args);

    if (matchedDocumentFile == null) return null;

    return DocumentFile.fromMap(matchedDocumentFile);
  }

  /// Return the updated `DocumentFile` to reflect name changes
  ///
  /// `this` shouldn't be used anymore
  Future<DocumentFile?> renameTo(String displayName) async {
    const kRenameTo = 'renameTo';

    const kDisplayNameArg = 'displayName';

    final args = <String, String>{
      ...uriArgs,
      kDisplayNameArg: displayName,
    };

    final updatedDocumentFile = await kDocumentFileChannel
        .invokeMapMethod<String, dynamic>(kRenameTo, args);

    if (updatedDocumentFile == null) return null;

    return DocumentFile.fromMap(updatedDocumentFile);
  }

  Future<DocumentFile?> parentFile() async {
    const kParentFile = 'parentFile';

    final parent = await kDocumentFileChannel
        .invokeMapMethod<String, dynamic>(kParentFile, {...uriArgs});

    if (parent == null) return null;

    return DocumentFile.fromMap(parent);
  }

  static DocumentFile fromMap(Map<String, dynamic> map) {
    return DocumentFile(
      isDirectory: map['isDirectory'],
      isFile: map['isFile'],
      isVirtual: map['isVirtual'],
      name: map['name'],
      type: map['type'],
      uri: Uri.parse(map['uri']),
    );
  }

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
