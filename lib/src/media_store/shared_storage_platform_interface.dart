import 'dart:io';

import 'package:flutter/services.dart';

import '../../shared_storage.dart';
import '../channels.dart';

abstract class SharedStoragePlatformInterface {
  Future<ScopedFile> buildScopedFileFrom(File file);

  Future<void> shareScopedFile(ScopedFile file);

  Future<void> shareUri(Uri uri);

  Future<void> shareFile(
    File file, {
    String? mimeType,
  });

  Future<void> shareFileFromPath(
    String filePath, {
    String? mimeType,
  });

  Future<ScopedFile> buildScopedFileFromUri(Uri uri);

  Future<ScopedDirectory> buildScopedDirectoryFrom(Directory directory);

  Future<ScopedDirectory> buildScopedDirectoryFromUri(Uri uri);

  Future<ScopedDirectory> pickDirectory({
    bool persist,
    bool grantWritePermission,
    Uri? initialUri,
    ScopedDirectory? initialDirectory,
  });

  Future<List<ScopedFile>> pickFiles({
    bool persist,
    bool grantWritePermission,
    Uri? initialUri,
    String mimeType,
    bool multiple,
    ScopedDirectory? initialDirectory,
  });

  Future<void> launchFileWithExternalApp(File file);
  Future<void> launchScopedFileWithExternalApp(ScopedFile file);
  Future<void> launchUriWithExternalApp(Uri uri);
}
