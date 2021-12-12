import 'dart:io';

import 'package:shared_storage/src/media_store/media_store_collection.dart';

import '../channels.dart';

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

  final publicDir = await kMediaStoreChannel.invokeMethod<String?>(
      kGetMediaStoreContentDirectory, args);

  if (publicDir == null) return null;

  return Directory(publicDir);
}
