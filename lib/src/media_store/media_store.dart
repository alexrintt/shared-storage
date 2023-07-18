import 'dart:io';

import 'package:flutter/services.dart';

import '../../shared_storage.dart';
import '../channels.dart';
import 'shared_storage_platform_interface.dart';

export 'package:mime/mime.dart';

class SharedStorage {
  const SharedStorage._();

  static SharedStoragePlatformInterface instance = SharedStorageImpl();

  static Future<ScopedFile> buildScopedFileFrom(File file) =>
      instance.buildScopedFileFrom(file);

  static Future<ScopedFile> buildScopedFileFromUri(Uri uri) =>
      instance.buildScopedFileFromUri(uri);

  static Future<void> shareScopedFile(ScopedFile scopedFile) =>
      instance.shareScopedFile(scopedFile);

  static Future<ScopedDirectory> buildScopedDirectoryFrom(
    Directory directory,
  ) =>
      instance.buildScopedDirectoryFrom(directory);

  static Future<ScopedDirectory> buildDirectoryFromUri(Uri uri) =>
      instance.buildScopedDirectoryFromUri(uri);

  static Future<void> launchFileWithExternalApp(File file) =>
      instance.launchFileWithExternalApp(file);

  static Future<void> launchScopedFileWithExternalApp(ScopedFile scopedFile) =>
      instance.launchScopedFileWithExternalApp(scopedFile);

  static Future<void> launchUriWithExternalApp(Uri uri) =>
      instance.launchUriWithExternalApp(uri);

  static Future<ScopedDirectory> pickDirectory({
    bool persist = true,
    bool grantWritePermission = true,
    Uri? initialUri,
    ScopedDirectory? initialDirectory,
  }) =>
      instance.pickDirectory(
        persist: persist,
        grantWritePermission: grantWritePermission,
        initialUri: initialUri,
        initialDirectory: initialDirectory,
      );

  static Future<List<ScopedFile>> pickFiles({
    bool persist = true,
    bool grantWritePermission = true,
    Uri? initialUri,
    String mimeType = '*/*',
    bool multiple = true,
    ScopedDirectory? initialDirectory,
  }) =>
      instance.pickFiles(
        persist: persist,
        grantWritePermission: grantWritePermission,
        initialUri: initialUri,
        mimeType: mimeType,
        multiple: multiple,
        initialDirectory: initialDirectory,
      );
}

class SharedStorageImpl implements SharedStoragePlatformInterface {
  factory SharedStorageImpl() => _instance ??= SharedStorageImpl._();

  SharedStorageImpl._();

  static SharedStorageImpl? _instance;

  @override
  Future<ScopedFile> buildScopedFileFrom(File file) {
    return ScopedFile.fromFile(file);
  }

  @override
  Future<void> shareScopedFile(ScopedFile scopedFile) {
    return shareUri(scopedFile.uri);
  }

  @override
  Future<ScopedFile> buildScopedFileFromUri(Uri uri) {
    return ScopedFile.fromUri(uri);
  }

  @override
  Future<ScopedDirectory> buildScopedDirectoryFrom(Directory directory) {
    return ScopedDirectory.fromDirectory(directory);
  }

  @override
  Future<ScopedDirectory> buildScopedDirectoryFromUri(Uri uri) {
    return ScopedDirectory.fromUri(uri);
  }

  @override
  Future<ScopedDirectory> pickDirectory({
    bool grantWritePermission = true,
    bool persist = true,
    Uri? initialUri,
    ScopedDirectory? initialDirectory,
  }) async {
    final Map<String, dynamic> args = <String, dynamic>{
      'grantWritePermission': grantWritePermission,
      'persistablePermission': persist,
      if (initialUri != null)
        'initialUri': initialUri.toString()
      else if (initialDirectory != null)
        'initialUri': initialDirectory.uri.toString(),
    };

    final String? selectedDirectoryUri = await kDocumentFileChannel
        .invokeMethod<String?>('openDocumentTree', args);

    if (selectedDirectoryUri == null) {
      throw SharedStorageDirectoryWasNotSelectedException(
        'Scoped directory was not selected. To handle this exception, you can use try-catch block. This is an exception to avoid returning null.',
        StackTrace.current,
      );
    }

    return ScopedDirectory.fromUri(Uri.parse(selectedDirectoryUri));
  }

  /// [Refer to details](https://developer.android.com/reference/android/content/Intent#ACTION_OPEN_DOCUMENT).
  @override
  Future<List<ScopedFile>> pickFiles({
    bool persist = true,
    bool grantWritePermission = true,
    Uri? initialUri,
    String mimeType = '*/*',
    bool multiple = true,
    ScopedDirectory? initialDirectory,
  }) async {
    const String kOpenDocument = 'openDocument';

    final Map<String, dynamic> args = <String, dynamic>{
      if (initialUri != null || initialDirectory != null)
        'initialUri': '${initialUri ?? initialDirectory?.uri}',
      'grantWritePermission': grantWritePermission,
      'persistablePermission': persist,
      'mimeType': mimeType,
      'multiple': multiple,
    };

    final List<dynamic>? selectedUriList =
        await kDocumentFileChannel.invokeListMethod(kOpenDocument, args);

    if (selectedUriList == null) {
      return <ScopedFile>[];
    }

    return Stream<dynamic>.fromIterable(selectedUriList)
        .map((dynamic e) => Uri.parse(e as String))
        .asyncMap((Uri uri) => ScopedFile.fromUri(uri))
        .toList();
  }

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
  @override
  Future<void> shareUri(
    Uri uri, {
    String? mimeType,
  }) {
    final Map<String, dynamic> args = <String, dynamic>{
      'uri': '$uri',
      'type': mimeType,
    };

    return kDocumentFileHelperChannel.invokeMethod<void>('shareUri', args);
  }

  @override
  Future<void> shareFile(
    File file, {
    String? mimeType,
  }) {
    return shareUri(Uri.file(file.path), mimeType: mimeType);
  }

  @override
  Future<void> shareFileFromPath(
    String filePath, {
    String? mimeType,
  }) {
    return shareUri(Uri.file(filePath), mimeType: mimeType);
  }

  @override
  Future<void> launchFileWithExternalApp(File file) async {
    return launchUriWithExternalApp(Uri.file(file.path));
  }

  /// {@template sharedstorage.saf.openDocumentFileWithResult}
  /// It's a convenience method to launch the default application associated
  /// with the given MIME type.
  ///
  /// Launch `ACTION_VIEW` intent to open the given document `uri`.
  ///
  /// Returns a [OpenDocumentFileResult] that allows you handle all edge-cases.
  /// {@endtemplate}
  @override
  Future<void> launchUriWithExternalApp(Uri uri) async {
    try {
      await kDocumentFileHelperChannel.invokeMethod<void>(
        'openDocumentFile',
        <String, String>{'uri': '$uri'},
      );
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'EXCEPTION_ACTIVITY_NOT_FOUND':
          throw SharedStorageExternalAppNotFoundException(
            'Did not find any app to handle the intent. Make sure you have an app that can handle the given uri: $uri',
            StackTrace.current,
          );
        case 'EXCEPTION_CANT_OPEN_FILE_DUE_SECURITY_POLICY':
          throw SharedStorageSecurityException(
            'The system denied read access to the given uri: $uri',
            StackTrace.current,
          );
        case 'EXCEPTION_CANT_OPEN_DOCUMENT_FILE':
        default:
          throw SharedStorageUnknownException(
            'Unknown exception when trying to open the given uri: $uri',
            StackTrace.current,
          );
      }
    }
  }

  @override
  Future<void> launchScopedFileWithExternalApp(ScopedFile file) {
    return launchUriWithExternalApp(file.uri);
  }
}
