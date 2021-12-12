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
