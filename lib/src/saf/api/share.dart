import 'dart:io';

import '../../channels.dart';

/// {@template sharedstorage.saf.share}
/// Start share intent for the given [uri].
///
/// To share a file, use [Uri.parse] passing the file absolute path as argument.
///
/// Note that this method can only share files that your app has permission over,
/// either by being in your app domain (e.g file from your app cache) or that is granted by [openDocumentTree].
///
/// Usage:
///
/// ```dart
/// try {
///   await shareUriOrFile(
///     uri: uri,
///     filePath: path,
///     file: file,
///   );
/// } on PlatformException catch (e) {
///   // The user clicked twice too fast, which created 2 share requests and the second one failed.
///   // Unhandled Exception: PlatformException(Share callback error, prior share-sheet did not call back, did you await it? Maybe use non-result variant, null, null).
///   log('Error when calling [shareFile]: $e');
///   return;
/// }
/// ```
/// {@endtemplate}
Future<void> shareUri(
  Uri uri, {
  String? type,
}) {
  final Map<String, dynamic> args = <String, dynamic>{
    'uri': '$uri',
    'type': type,
  };

  return kDocumentFileHelperChannel.invokeMethod<void>('shareUri', args);
}

/// Alias for [shareUri].
Future<void> shareFile({File? file, String? path}) {
  return shareUriOrFile(filePath: path, file: file);
}

/// Alias for [shareUri].
Future<void> shareUriOrFile({String? filePath, File? file, Uri? uri}) {
  return shareUri(
    _getShareableUriFrom(file: file, filePath: filePath, uri: uri),
  );
}

/// Helper function to get the shareable URI from [file], [filePath] or the [uri] itself.
///
/// Usage:
///
/// ```dart
/// shareUri(getShareableUri(...));
/// ```
Uri _getShareableUriFrom({String? filePath, File? file, Uri? uri}) {
  if (filePath == null && file == null && uri == null) {
    throw ArgumentError.value(
      null,
      'getShareableUriFrom',
      'Tried to call [getShareableUriFrom] or with all arguments ({String? filePath, File? file, Uri? uri}) set to [null].',
    );
  }

  late Uri target;

  if (uri != null) {
    target = uri;
  } else if (filePath != null) {
    target = Uri.parse(filePath);
  } else if (file != null) {
    target = Uri.parse(file.absolute.path);
  }

  return target;
}
