import 'dart:typed_data';

/// Represent the bitmap/image of a document.
///
/// Usually the thumbnail of the document.
///
/// The bitmap is represented as byte array [Uint8List].
///
/// Should be used to show a list/grid preview of a file list.
///
/// See also [getDocumentThumbnail].
class DocumentBitmap {
  const DocumentBitmap({
    required this.bytes,
    required this.uri,
    required this.width,
    required this.height,
    required this.byteCount,
    required this.density,
  });

  factory DocumentBitmap.fromMap(Map<String, dynamic> map) {
    return DocumentBitmap(
      uri: (() {
        final String? uri = map['uri'] as String?;

        if (uri == null) return null;

        return Uri.parse(uri);
      })(),
      width: map['width'] as int?,
      height: map['height'] as int?,
      bytes: map['bytes'] as Uint8List?,
      byteCount: map['byteCount'] as int?,
      density: map['density'] as int?,
    );
  }

  final Uint8List? bytes;
  final Uri? uri;
  final int? width;
  final int? height;
  final int? byteCount;
  final int? density;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uri': '$uri',
      'width': width,
      'height': height,
      'bytes': bytes,
      'byteCount': byteCount,
      'density': density,
    };
  }

  @override
  bool operator ==(Object other) {
    if (other is! DocumentBitmap) return false;

    return other.byteCount == byteCount &&
        other.width == width &&
        other.height == height &&
        other.uri == uri &&
        other.density == density &&
        other.bytes == bytes;
  }

  @override
  int get hashCode =>
      Object.hash(width, height, uri, density, byteCount, bytes);
}
