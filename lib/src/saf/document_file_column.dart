/// Representation of the available columns of `DocumentsContract.Document.<Column>`
///
/// [Refer to details](https://developer.android.com/reference/android/provider/DocumentsContract.Document)
class DocumentFileColumn {
  const DocumentFileColumn._(this._id);

  final String _id;

  static const String _kPrefix = 'DocumentFileColumn';

  /// Equivalent to [`COLUMN_DOCUMENT_ID`](https://developer.android.com/reference/android/provider/DocumentsContract.Document#COLUMN_DOCUMENT_ID)
  static const DocumentFileColumn id =
      DocumentFileColumn._('$_kPrefix.COLUMN_DOCUMENT_ID');

  /// Equivalent to [`COLUMN_DISPLAY_NAME`](https://developer.android.com/reference/android/provider/DocumentsContract.Document#COLUMN_DISPLAY_NAME)
  static const DocumentFileColumn displayName =
      DocumentFileColumn._('$_kPrefix.COLUMN_DISPLAY_NAME');

  /// Equivalent to [`COLUMN_MIME_TYPE`](https://developer.android.com/reference/android/provider/DocumentsContract.Document#COLUMN_MIME_TYPE)
  static const DocumentFileColumn mimeType =
      DocumentFileColumn._('$_kPrefix.COLUMN_MIME_TYPE');

  /// Equivalent to [`COLUMN_LAST_MODIFIED`](https://developer.android.com/reference/android/provider/DocumentsContract.Document#COLUMN_LAST_MODIFIED)
  static const DocumentFileColumn lastModified =
      DocumentFileColumn._('$_kPrefix.COLUMN_LAST_MODIFIED');

  /// Equivalent to [`COLUMN_SIZE`](https://developer.android.com/reference/android/provider/DocumentsContract.Document#COLUMN_SIZE)
  static const DocumentFileColumn size =
      DocumentFileColumn._('$_kPrefix.COLUMN_SIZE');

  /// Equivalent to [`COLUMN_SUMMARY`](https://developer.android.com/reference/android/provider/DocumentsContract.Document#COLUMN_SUMMARY)
  static const DocumentFileColumn summary =
      DocumentFileColumn._('$_kPrefix.COLUMN_SUMMARY');

  /// Equivalent to [`COLUMN_FLAGS`](https://developer.android.com/reference/android/provider/DocumentsContract.Document#COLUMN_FLAGS)
  static const DocumentFileColumn flags =
      DocumentFileColumn._('$_kPrefix.COLUMN_FLAGS');

  /// Equivalent to [`COLUMN_ICON`](https://developer.android.com/reference/android/provider/DocumentsContract.Document#COLUMN_ICON)
  static const DocumentFileColumn icon =
      DocumentFileColumn._('$_kPrefix.COLUMN_FLAGS');

  @override
  bool operator ==(Object other) {
    return other is DocumentFileColumn && other._id == _id;
  }

  static const List<DocumentFileColumn> values = <DocumentFileColumn>[
    id,
    displayName,
    mimeType,
    lastModified,
    size,
    summary,
    flags,
    icon,
  ];

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() => _id;
}
