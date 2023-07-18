// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:path/path.dart';

import '../../../shared_storage.dart';
import '../../channels.dart';
import '../../saf/common/generate_id.dart';

extension Also<T> on T {
  T also(void Function(T) fn) {
    fn(this);
    return this;
  }
}

abstract class ScopedFile implements ScopedFileSystemEntity {
  const ScopedFile();

  String get mimeType;
  int get length;

  static Future<ScopedFile> fromUri(Uri uri) {
    return _ScopedFile.fromUri(uri);
  }

  static ScopedFile fromMap(Map<String, dynamic> map) {
    return _ScopedFile.fromMap(map);
  }

  static Future<ScopedFile> fromFile(File file) {
    return _ScopedFile.fromFile(file);
  }

  Stream<Uint8List> openRead([int start = 0, int? end]);
  Future<Uint8List> readAsBytes([int start = 0, int? end]);
  Future<String> readAsString({Encoding encoding = utf8});
  Future<List<String>> readAsLines({Encoding encoding = utf8});

  void openWrite(
    Stream<Uint8List> byteStream, {
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
  });
  Future<void> writeAsBytes(
    Uint8List bytes, {
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  });
  Future<void> writeAsString(
    String contents, {
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  });
}

class _ScopedFile implements ScopedFile {
  const _ScopedFile({
    required this.id,
    required this.mimeType,
    required this.displayName,
    required this.length,
    required this.uri,
    required this.parentUri,
    required this.lastModified,
  });

  static const String kOctetStreamMimeType = 'application/octet-stream';
  static const String kDefaultMimeType = kOctetStreamMimeType;

  @override
  final DateTime lastModified;

  @override
  final int length;

  @override
  final Uri uri;

  @override
  final Uri? parentUri;

  @override
  final String id;

  @override
  final String mimeType;

  @override
  final String displayName;

  // Will retrive to the header bytes of the file
  // See also:
  // - https://en.wikipedia.org/wiki/List_of_file_signatures
  // - https://pub.dev/packages/mime
  static Future<Uint8List> _getHeaderBytes(
    Stream<Uint8List> fileByteStream, {
    int headerBytesLength = k1KB,
  }) async {
    final List<int> headerBytes = <int>[];

    await fileByteStream
        .takeWhile((_) => headerBytes.length < headerBytesLength)
        .forEach(headerBytes.addAll);

    return Uint8List.fromList(headerBytes);
  }

  static Future<ScopedFile> fromUri(Uri uri) async {
    if (uri.scheme == 'file') {
      assert(!uri.toString().endsWith('/'));

      // File URI and Directory URI both use 'file' scheme the difference is that directory URIs ends with /.
      final bool isDirectory = uri.toFilePath().endsWith('/');

      final FileSystemEntity entity =
          isDirectory ? Directory.fromUri(uri) : File.fromUri(uri);

      if (!entity.existsSync()) {
        throw SharedStorageFileNotFoundException(
          '${entity.path} does not exist. It either means the file actually does not exist or maybe you do not have permission to read the file',
          StackTrace.current,
        );
      }

      final FileStat stat = entity.statSync();
      final File file = File.fromUri(uri);

      final Uint8List headerBytes =
          await _getHeaderBytes(file.openRead().map(Uint8List.fromList));

      return _ScopedFile(
        mimeType: lookupMimeType(file.path, headerBytes: headerBytes) ??
            kDefaultMimeType,
        displayName: basename(file.path),
        id: entity.path,
        length: stat.size,
        uri: uri,
        lastModified: stat.modified,
        parentUri: entity.parent.uri,
      );
    } else {
      final Map<String, dynamic>? response =
          await kMediaStoreChannel.invokeMapMethod<String, dynamic>(
        'getScopedFileSystemEntityFromUri',
        <String, dynamic>{
          'uri': uri.toString(),
        },
      );

      return _ScopedFile.fromMap(response!);
    }
  }

  static Future<ScopedFile> fromFile(File file) {
    return _ScopedFile.fromUri(Uri.file(file.path));
  }

  @override
  Future<FileSystemEntity> delete({bool recursive = false}) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  /// {@template sharedstorage.saf.exists}
  ///  Equivalent to `DocumentFile.exists`.
  ///
  /// Verify wheter or not a given [uri] exists.
  ///
  /// [Refer to details](https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#exists()).
  /// {@endtemplate}
  @override
  Future<bool> exists() {
    return kDocumentFileChannel.invokeMethod<bool>('exists', <String, String>{
      'uri': '$uri',
    }).then((bool? value) => value ?? false);
  }

  @override
  Future<RandomAccessFile> open({FileMode mode = FileMode.read}) {
    // TODO: implement open
    throw UnimplementedError();
  }

  /// {@template sharedstorage.ScopedFile.openRead}
  /// Read the given [uri] contents with lazy-strategy using [Stream]s.
  ///
  /// Each [Stream] event contains only a small fraction of the [uri] bytes of size [bufferSize].
  ///
  /// e.g let target [uri] be a 500MB file and [bufferSize] is 1MB, the returned [Stream] will emit 500 events, each one containing a [Uint8List] of size 1MB (may vary but that's the idea).
  ///
  /// Since only chunks of the files are actually loaded, there are no performance gaps or the risk of app crash.
  ///
  /// If that happens, provide the [bufferSize] with a lower limit.
  ///
  /// Greater [bufferSize] values will speed-up reading but will increase [OutOfMemoryError] chances.
  /// {@endtemplate}

  @override
  Stream<Uint8List> openRead([
    int? start,
    int? end,
    int bufferSize = k1MB, // max 16 bit integer
  ]) {
    if (uri.scheme == 'file') {
      return _openReadFile(start, end);
    } else {
      return _openReadScopedFile(start, end, bufferSize);
    }
  }

  Stream<Uint8List> _openReadFile([int? start, int? end]) {
    return File.fromUri(uri).openRead(start, end).map(Uint8List.fromList);
  }

  static const int kDefaultBufferSize = k1MB;

  Stream<Uint8List> _openReadScopedFile([
    int? start,
    int? end,
    int? bufferSize,
  ]) async* {
    assert(start == null || start >= 0);
    assert(end == null || end >= 0);

    final String callId = generateTimeBasedId();

    final int initial = start ?? 0; // inclusive
    final int? last = end; // inclusive
    final int? diff = last != null ? last - initial : null;
    final int byteChunkSize = bufferSize ?? kDefaultBufferSize;

    int offset = start ?? 0;
    int totalRead = 0;

    await kDocumentFileChannel.invokeMethod<void>(
      'openInputStream',
      <String, String>{'uri': uri.toString(), 'callId': callId},
    );

    // Offset must be applied only to the first byte chunk
    int currentOffset() {
      final int current = offset;
      offset = 0;
      return current;
    }

    int calcBufferSize() {
      if (diff == null) {
        // Read until the EOF
        return byteChunkSize;
      }

      final int pendingByteChunkSize = diff - totalRead;

      return min(pendingByteChunkSize, byteChunkSize);
    }

    Future<Uint8List?> readByteChunk() async {
      final Map<String, dynamic>? result =
          await kDocumentFileChannel.invokeMapMethod<String, dynamic>(
        'readInputStream',
        <String, dynamic>{
          'callId': callId,
          'offset': currentOffset(),
          'bufferSize': calcBufferSize(),
        },
      );

      if (result == null) {
        return null;
      }

      final int readBufferSize = result['readBufferSize'] as int;

      if (readBufferSize == -1) {
        return null;
      }

      return (result['bytes'] as Uint8List)
          .also((Uint8List bytes) => totalRead += bytes.length);
    }

    while (true) {
      final Uint8List? byteChunk = await readByteChunk();

      if (byteChunk == null) {
        break;
      } else {
        yield byteChunk;
      }
    }

    await kDocumentFileChannel.invokeMethod<void>(
      'closeInputStream',
      <String, String>{
        'callId': callId,
      },
    );
  }

  @override
  void openWrite(
    Stream<Uint8List> byteStream, {
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
  }) {
    // TODO: implement openWrite
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> readAsBytes([int start = 0, int? end]) {
    return openRead(start, end).reduce(
      (Uint8List previous, Uint8List element) =>
          Uint8List.fromList(previous + element),
    );
  }

  @override
  Future<List<String>> readAsLines({Encoding encoding = utf8}) {
    return openRead()
        .map(encoding.decode)
        .transform(const LineSplitter())
        .toList();
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) {
    return openRead()
        .map(encoding.decode)
        .reduce((String previous, String element) => previous + element);
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
  FutureOr<ScopedFileSystemEntity> rename(String displayName) {
    // TODO: implement rename
    throw UnimplementedError();
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'lastModified': lastModified.millisecondsSinceEpoch,
      'length': length,
      'uri': uri.toString(),
      'parentUri': parentUri?.toString(),
      'id': id,
      'mimeType': mimeType,
      'displayName': displayName,
    };
  }

  factory _ScopedFile.fromMap(Map<String, dynamic> map) {
    return _ScopedFile(
      lastModified:
          DateTime.fromMillisecondsSinceEpoch(map['lastModified'] as int),
      length: map['length'] as int,
      uri: Uri.parse(map['uri'] as String),
      parentUri: map['parentUri'] != null
          ? Uri.parse(map['parentUri'] as String)
          : null,
      id: map['id'] as String,
      mimeType: map['mimeType'] as String,
      displayName: map['displayName'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory _ScopedFile.fromJson(String source) =>
      _ScopedFile.fromMap(json.decode(source) as Map<String, dynamic>);

  /// {@template sharedstorage.saf.canRead}
  /// Equivalent to `DocumentFile.canRead`.
  ///
  /// [Refer to details](https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#canRead()).
  /// {@endtemplate}
  @override
  FutureOr<bool> canRead() async {
    return kDocumentFileChannel.invokeMethod<bool>('canRead', <String, String>{
      'uri': '$uri',
    }).then((bool? value) => value ?? false);
  }

  /// {@template sharedstorage.saf.canWrite}
  /// Equivalent to `DocumentFile.canWrite`.
  ///
  /// [Refer to details](https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#canWrite()).
  /// {@endtemplate}
  @override
  FutureOr<bool> canWrite() async {
    return kDocumentFileChannel.invokeMethod<bool>('canWrite', <String, String>{
      'uri': '$uri',
    }).then((bool? value) => value ?? false);
  }

  @override
  Future<void> writeAsBytes(
    Uint8List bytes, {
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  }) {
    // TODO: implement writeAsBytes
    throw UnimplementedError();
  }

  @override
  Future<void> writeAsString(
    String contents, {
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  }) {
    // TODO: implement writeAsString
    throw UnimplementedError();
  }
}
