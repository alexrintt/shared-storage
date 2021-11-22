/// Description of a single Uri permission grant.
/// This grants may have been created via `Intent#FLAG_GRANT_READ_URI_PERMISSION`,
/// etc when sending an `Intent`, or explicitly through `Context#grantUriPermission(String, android.net.Uri, int)`.
///
/// [Refer to details](https://developer.android.com/reference/android/content/UriPermission)
class UriPermission {
  final bool isReadPermission;
  final bool isWritePermission;
  final int persistedTime;
  final Uri uri;

  const UriPermission(
      {required this.isReadPermission,
      required this.isWritePermission,
      required this.persistedTime,
      required this.uri});

  @override
  bool operator ==(Object other) =>
      other is UriPermission &&
      isReadPermission == other.isReadPermission &&
      isWritePermission == other.isWritePermission &&
      persistedTime == other.persistedTime &&
      uri == other.uri;

  @override
  int get hashCode =>
      Object.hash(isReadPermission, isWritePermission, persistedTime, uri);

  static UriPermission fromMap(Map<String, dynamic> map) {
    return UriPermission(
      isReadPermission: map['isReadPermission'],
      isWritePermission: map['isWritePermission'],
      persistedTime: map['persistedTime'],
      uri: Uri.parse(map['uri']),
    );
  }

  Map<String, dynamic> toMap(Map<String, dynamic> map) {
    return <String, dynamic>{
      'isReadPermission': isReadPermission,
      'isWritePermission': isWritePermission,
      'persistedTime': persistedTime,
      'uri': '$uri',
    };
  }

  @override
  String toString() => 'UriPermission('
      'isReadPermission: $isReadPermission, '
      'isWritePermission: $isWritePermission, '
      'persistedTime: $persistedTime, '
      'uri: $uri)';
}
