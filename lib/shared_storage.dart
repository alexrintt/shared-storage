import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

/// Method Channel of this plugin
///
/// Flutter uses this to communicate with native Android
const _kChannel = MethodChannel('io.lakscastro.plugins/sharedstorage');

/// Representation of the [android.provider.MediaStore] Android SDK
///
/// [Refer to details](https://developer.android.com/reference/android/provider/MediaStore#summary)
class MediaStoreCollection {
  final String id;

  const MediaStoreCollection._(this.id);

  static const _kPrefix = 'MediaStoreCollection';

  /// Available for Android [10 to 12]
  ///
  /// Equivalent to:
  /// - [MediaStore.Audio]
  static const audio = MediaStoreCollection._('$_kPrefix.Audio');

  /// Available for Android [10 to 12]
  ///
  /// Equivalent to:
  /// - [MediaStore.Downloads]
  static const downloads = MediaStoreCollection._('$_kPrefix.Downloads');

  /// Available for Android [10 to 12]
  ///
  /// Equivalent to:
  /// - [MediaStore.Images]
  static const images = MediaStoreCollection._('$_kPrefix.Images');

  /// Available for Android [10 to 12]
  ///
  /// Equivalent to:
  /// - [MediaStore.Video]
  static const video = MediaStoreCollection._('$_kPrefix.Video');

  @override
  bool operator ==(Object other) {
    return other is MediaStoreCollection && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => id;
}

/// Enumeration to all fields of [android.os.Environment]
/// class available to API level 16 or higher
///
/// - You can also create a custom [EnvironmentDirectory]
/// by using [custom] constructor
///
/// - This generally returns a directory pointing to `/storage/emulated/0/[this]`
///
/// [Refer to details](https://developer.android.com/reference/android/os/Environment#fields_1)
class EnvironmentDirectory {
  final String id;

  const EnvironmentDirectory._(this.id);

  /// Define a custom [folder]
  const EnvironmentDirectory.custom(String folder) : id = folder;

  static const _kPrefix = 'EnvironmentDirectory';

  /// Available for Android [4.1 to 9.0]
  ///
  /// Equivalent to [Environment.DIRECTORY_ALARMS]
  static const alarms = EnvironmentDirectory._('$_kPrefix.Alarms');

  /// Available for Android [4.1 to 9]
  ///
  /// Equivalent to:
  /// - [Environment.DIRECTORY_DCIM] on Android [4.1 to 9]
  static const dcim = EnvironmentDirectory._('$_kPrefix.DCIM');

  /// Available for Android [4.1 to 9]
  ///
  /// Equivalent to:
  /// - [Environment.DIRECTORY_DOWNLOADS] on Android [4.1 to 9]
  static const downloads = EnvironmentDirectory._('$_kPrefix.Downloads');

  /// Available for Android [4.1 to 9]
  ///
  /// - [Environment.DIRECTORY_MOVIES] on Android [4.1 to 9]
  static const movies = EnvironmentDirectory._('$_kPrefix.Movies');

  /// Available for Android [4.1 to 9]
  ///
  /// - [Environment.DIRECTORY_MUSIC] on Android [4.1 to 9]
  static const music = EnvironmentDirectory._('$_kPrefix.Music');

  /// Available for Android [4.1 to 9]
  ///
  /// - [Environment.DIRECTORY_NOTIFICATIONS] on Android [4.1 to 9]
  static const notifications =
      EnvironmentDirectory._('$_kPrefix.Notifications');

  /// Available for Android [4.1 to 9]
  ///
  /// - [Environment.DIRECTORY_PICTURES] on Android [4.1 to 9]
  static const pictures = EnvironmentDirectory._('$_kPrefix.Pictures');

  /// Available for Android [4.1 to 9]
  ///
  /// - [Environment.DIRECTORY_PODCASTS] on Android [4.1 to 9]
  static const podcasts = EnvironmentDirectory._('$_kPrefix.Podcasts');

  /// Available for Android [4.1 to 9]
  ///
  /// - [Environment.DIRECTORY_RINGTONES] on Android [4.1 to 9]
  static const ringtones = EnvironmentDirectory._('$_kPrefix.Ringtones');

  @override
  bool operator ==(Object other) {
    return other is EnvironmentDirectory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => id;
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

  final publicDir = await _kChannel.invokeMethod<String>(
      kGetExternalStoragePublicDirectory, args);

  if (publicDir == null) return null;

  return Directory(publicDir);
}

/// The contract between the media provider and applications.
///
/// Can get the absolute path given a [collection]
///
/// [Refer to details](https://developer.android.com/reference/android/provider/MediaStore#summary)
Future<Directory?> getMediaStoreContentDirectory(
    MediaStoreCollection collection) async {
  const kGetMediaStoreContentDirectory = 'getMediaStoreContentDirectory';
  const kCollectionArg = 'collection';

  final args = <String, String>{kCollectionArg: '$collection'};

  final publicDir =
      await _kChannel.invokeMethod(kGetMediaStoreContentDirectory, args);

  if (publicDir == null) return null;

  return Directory(publicDir);
}

/// Return root of the "system" partition holding the core Android OS.
/// Always present and mounted read-only.
///
/// Equivalent to [Environment.getRootDirectory]
///
/// [Refer to details](https://developer.android.com/reference/android/os/Environment#getRootDirectory())
Future<Directory?> getRootDirectory() async {
  const kGetRootDirectory = 'getRootDirectory';

  final publicDir = await _kChannel.invokeMethod(kGetRootDirectory);

  if (publicDir == null) return null;

  return Directory(publicDir);
}
