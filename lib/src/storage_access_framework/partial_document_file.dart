import '../../shared_storage.dart';

/// Represent the same entity as `DocumentFile` but will be lazily loaded
/// by `listFilesAsStream` method with dynamic
/// properties and query metadata context
///
/// _Note: Can't be instantiated_
class PartialDocumentFile {
  const PartialDocumentFile._({required this.data, required this.metadata});

  factory PartialDocumentFile.fromMap(Map<String, dynamic> map) {
    return PartialDocumentFile._(
      data: (() {
        final data = map['data'] as Map?;

        if (data == null) return null;

        return <DocumentFileColumn, dynamic>{
          for (final value in DocumentFileColumn.values)
            if (data['$value'] != null) value: data['$value'],
        };
      })(),
      metadata: QueryMetadata.fromMap(Map.from(map['metadata'] as Map)),
    );
  }

  final Map<DocumentFileColumn, dynamic>? data;
  final QueryMetadata? metadata;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'data': data,
      if (metadata != null) 'metadata': metadata?.toMap(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (other is! PartialDocumentFile) return false;

    return other.data == data && other.metadata == metadata;
  }

  @override
  int get hashCode => Object.hash(data, metadata);
}

/// Represents the metadata that the given `PartialDocumentFile` was got by
/// the `contentResolver.query(uri, ...metadata)` method
///
/// _Note: Can't be instantiated_
class QueryMetadata {
  const QueryMetadata._({
    required this.parentUri,
    required this.rootUri,
    required this.isDirectory,
    required this.uri,
  });

  factory QueryMetadata.fromMap(Map<String, dynamic> map) {
    return QueryMetadata._(
      parentUri: _parseUri(map['parentUri'] as String?),
      rootUri: _parseUri(map['rootUri'] as String?),
      isDirectory: map['isDirectory'] as bool?,
      uri: _parseUri(map['uri'] as String?),
    );
  }

  final Uri? parentUri;
  final Uri? rootUri;
  final bool? isDirectory;
  final Uri? uri;

  static Uri? _parseUri(String? uri) {
    if (uri == null) return null;

    return Uri.parse(uri);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'parentUri': '$parentUri',
      'rootUri': '$rootUri',
      'isDirectory': isDirectory,
      'uri': uri,
    };
  }

  @override
  bool operator ==(Object other) {
    if (other is! QueryMetadata) return false;

    return other.parentUri == parentUri &&
        other.rootUri == rootUri &&
        other.isDirectory == isDirectory &&
        other.uri == uri;
  }

  @override
  int get hashCode => Object.hash(parentUri, rootUri, isDirectory, uri);
}
