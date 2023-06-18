import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import '../../channels.dart';
import '../../common/functional_extender.dart';
import '../common/generate_id.dart';
import '../models/barrel.dart';

/// {@template sharedstorage.saf.getDocumentContentAsString}
/// Helper method to read document using
/// `getDocumentContent` and get the content as String instead as `Uint8List`.
/// {@endtemplate}
Future<String?> getDocumentContentAsString(
  Uri uri, {
  bool throwIfError = false,
}) async {
  return utf8.decode(await getDocumentContent(uri));
}

/// {@template sharedstorage.saf.getDocumentContent}
/// Get content of a given document [uri].
///
/// This method is an alias for [getDocumentContentAsStream] that merges every file chunk into the memory.
///
/// Be careful: this method crashes the app if the target [uri] is a large file, prefer [getDocumentContentAsStream] instead.
/// {@endtemplate}
Future<Uint8List> getDocumentContent(Uri uri) {
  return getDocumentContentAsStream(uri).reduce(
    (Uint8List previous, Uint8List element) => Uint8List.fromList(
      <int>[
        ...previous,
        ...element,
      ],
    ),
  );
}

const int k1B = 1;
const int k1KB = k1B * 1024;
const int k512KB = k1B * 512;
const int k1MB = k1KB * 1024;
const int k512MB = k1MB * 512;
const int k1GB = k1MB * 1024;
const int k1TB = k1GB * 1024;
const int k1PB = k1TB * 1024;

/// {@template sharedstorage.getDocumentContentAsStream}
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
Stream<Uint8List> getDocumentContentAsStream(
  Uri uri, {
  int bufferSize = k1MB,
}) {
  final String callId = generateTimeBasedId();
  late final StreamController<Uint8List> controller;

  bool paused = false;

  Stream<Uint8List> readFileInputStream() async* {
    int readBufferSize = 0;

    while (readBufferSize != -1 && !paused) {
      final Map<String, dynamic>? result =
          await kDocumentFileChannel.invokeMapMethod<String, dynamic>(
        'readInputStream',
        <String, dynamic>{
          'callId': callId,
          'offset': 0,
          'bufferSize': bufferSize,
        },
      );

      if (result != null) {
        readBufferSize = result['readBufferSize'] as int;
        yield result['bytes'] as Uint8List;
      }
    }
  }

  void onListen() {
    // Platform code is optimized to not create a new input stream if
    // a same [callId] is provided, so there are no problems in calling this several times.
    kDocumentFileChannel.invokeMethod<void>(
      'openInputStream',
      <String, String>{'uri': uri.toString(), 'callId': callId},
    );

    controller.addStream(readFileInputStream());
  }

  FutureOr<void> onCancel() {
    kDocumentFileChannel.invokeMethod<void>(
      'closeInputStream',
      <String, String>{'callId': callId},
    );
    controller.close();
  }

  void onPause() {
    paused = true;
  }

  void onResume() {
    paused = false;
    readFileInputStream();
  }

  controller = StreamController<Uint8List>(
    onCancel: onCancel,
    onListen: onListen,
    onPause: onPause,
    onResume: onResume,
  );

  return controller.stream;
}

/// {@template sharedstorage.saf.getDocumentThumbnail}
/// Equivalent to `DocumentsContract.getDocumentThumbnail`.
///
/// [Refer to details](https://developer.android.com/reference/android/provider/DocumentsContract#getDocumentThumbnail(android.content.ContentResolver,%20android.net.Uri,%20android.graphics.Point,%20android.os.CancellationSignal)).
/// {@endtemplate}
Future<DocumentBitmap?> getDocumentThumbnail({
  required Uri uri,
  required double width,
  required double height,
}) async {
  final Map<String, dynamic> args = <String, dynamic>{
    'uri': '$uri',
    'width': width,
    'height': height,
  };

  final Map<String, dynamic>? bitmap = await kDocumentsContractChannel
      .invokeMapMethod<String, dynamic>('getDocumentThumbnail', args);

  return bitmap?.apply((Map<String, dynamic> b) => DocumentBitmap.fromMap(b));
}
