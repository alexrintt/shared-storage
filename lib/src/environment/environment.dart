import 'dart:io';

import '../channels.dart';
import 'environment_directory.dart';

/// Return root of the "system" partition holding the core Android OS.
/// Always present and mounted read-only.
///
/// Equivalent to [Environment.getRootDirectory]
///
/// [Refer to details](https://developer.android.com/reference/android/os/Environment#getRootDirectory())
Future<Directory?> getRootDirectory() async {
  const kGetRootDirectory = 'getRootDirectory';

  final publicDir =
      await kEnvironmentChannel.invokeMethod<String?>(kGetRootDirectory);

  if (publicDir == null) return null;

  return Directory(publicDir);
}

/// Get a top-level shared/external storage directory for placing files of a
/// particular type. This is where the user will typically place and manage
/// their own files, so you should be careful about what you put here to
/// ensure you don't erase their files or get in the way
/// of their own organization.
///
/// _Added in API level 8_
///
/// _Deprecated in API level 29_
///
/// Equivalent to [Environment.getExternalStoragePublicDirectory] Android method
///
/// Throws [UnsupportedError] if not available on current Android version
///
/// [Refer to details](https://developer.android.com/reference/android/os/Environment#getExternalStoragePublicDirectory(java.lang.String))
Future<Directory?> getExternalStoragePublicDirectory(
    EnvironmentDirectory directory) async {
  const kGetExternalStoragePublicDirectory =
      'getExternalStoragePublicDirectory';
  const kDirectoryArg = 'directory';

  final args = <String, String>{kDirectoryArg: '$directory'};

  final publicDir = await kEnvironmentChannel.invokeMethod<String?>(
      kGetExternalStoragePublicDirectory, args);

  if (publicDir == null) return null;

  return Directory(publicDir);
}

/// Return the primary shared/external storage directory.
/// This directory may not currently be accessible
/// if it has been mounted by the user on their
/// computer, has been removed from the device,
/// or some other problem has happened.
/// You can determine its current state with getExternalStorageState().
///
/// [Refer to details](https://developer.android.com/reference/android/os/Environment#getExternalStorageDirectory())
Future<Directory?> getExternalStorageDirectory() async {
  const kGetExternalStorageDirectory = 'getExternalStorageDirectory';

  final publicDir = await kEnvironmentChannel
      .invokeMethod<String>(kGetExternalStorageDirectory);

  if (publicDir == null) return null;

  return Directory(publicDir);
}
