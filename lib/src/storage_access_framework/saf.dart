import 'package:shared_storage/shared_storage.dart';
import 'package:shared_storage/src/channels.dart';
import 'package:shared_storage/src/storage_access_framework/document_bitmap.dart';
import 'package:shared_storage/src/storage_access_framework/uri_permission.dart';

/// Start Activity Action: Allow the user to pick a directory subtree.
/// When invoked, the system will display the various `DocumentsProvider`
/// instances installed on the device, letting the user navigate through them.
/// Apps can fully manage documents within the returned directory.
///
/// [Refer to details](https://developer.android.com/reference/android/content/Intent#ACTION_OPEN_DOCUMENT_TREE)
///
/// TODO: Implement [initialDir] param to
/// support the initial directory of the directory picker
Future<Uri?> openDocumentTree({bool grantWritePermission = true}) async {
  const kOpenDocumentTree = 'openDocumentTree';

  const kGrantWritePermission = 'grantWritePermission';

  final args = <String, dynamic>{kGrantWritePermission: grantWritePermission};

  final selectedDirectoryUri =
      await kDocumentFileChannel.invokeMethod<String?>(kOpenDocumentTree, args);

  if (selectedDirectoryUri == null) return null;

  return Uri.parse(selectedDirectoryUri);
}

/// Returns an `List<URI>` with all persisted [URI]
///
/// To persist an [URI] call `openDocumentTree`
/// and to remove an persisted [URI] call `releasePersistableUriPermission`
Future<List<UriPermission>?> persistedUriPermissions() async {
  const kPersistedUriPermissions = 'persistedUriPermissions';

  final persistedUriPermissions =
      await kDocumentFileChannel.invokeListMethod(kPersistedUriPermissions);

  if (persistedUriPermissions == null) return null;

  return persistedUriPermissions
      .map((e) => UriPermission.fromMap(Map.from(e)))
      .toList();
}

/// Will revoke an persistable URI
///
/// Call this when your App no longer wants the permission of an [URI] returned
/// by `openDocumentTree` method
///
/// To get the current persisted [URI]s call `persistedUriPermissions`
Future<void> releasePersistableUriPermission(Uri directory) async {
  const kReleasePersistableUriPermission = 'releasePersistableUriPermission';

  const kUri = 'uri';

  final args = <String, String>{kUri: '$directory'};

  await kDocumentFileChannel.invokeMethod(
      kReleasePersistableUriPermission, args);
}

/// Convenient method to verify if a given [uri]
/// is allowed to be write or read from SAF API's
///
/// This uses the `releasePersistableUriPermission` method to get the List
/// of allowed [URI]s then will verify if the [uri] is included in
Future<bool> isPersistedUri(Uri uri) async {
  final persistedUris = await persistedUriPermissions();

  return persistedUris?.any((persistedUri) => persistedUri.uri == uri) ?? false;
}

/// Equivalent to `DocumentFile.canRead`
///
/// [Refer to details](https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#canRead())
Future<bool?> canRead(Uri uri) async {
  const kCanRead = 'canRead';

  const kUri = 'uri';

  final args = {kUri: '$uri'};

  return await kDocumentFileChannel.invokeMethod<bool>(kCanRead, args);
}

/// Equivalent to `DocumentFile.canWrite`
///
/// [Refer to details](https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#canWrite())
Future<bool?> canWrite(Uri uri) async {
  const kCanWrite = 'canWrite';

  const kUri = 'uri';

  final args = {kUri: '$uri'};

  return await kDocumentFileChannel.invokeMethod<bool>(kCanWrite, args);
}

/// Equivalent to `DocumentsContract.getDocumentThumbnail`
///
/// [Refer to details](https://developer.android.com/reference/android/provider/DocumentsContract#getDocumentThumbnail(android.content.ContentResolver,%20android.net.Uri,%20android.graphics.Point,%20android.os.CancellationSignal))
Future<DocumentBitmap?> getDocumentThumbnail({
  required Uri rootUri,
  required String documentId,
  required double width,
  required double height,
}) async {
  const kGetDocumentThumbnail = 'getDocumentThumbnail';

  const kRootUri = 'rootUri';
  const kDocumentId = 'documentId';
  const kWidth = 'width';
  const kHeight = 'height';

  final args = {
    kRootUri: '$rootUri',
    kDocumentId: documentId,
    kWidth: width,
    kHeight: height,
  };

  final bitmap = await kDocumentsContractChannel
      .invokeMapMethod<String, dynamic>(kGetDocumentThumbnail, args);

  if (bitmap == null) return null;

  return DocumentBitmap.fromMap(bitmap);
}

/// Emits a new event for each child document file
///
/// Works with small and large data file sets
///
/// ```dart
/// /// Usage:
///
/// final myState = <PartialDocumentFile>[];
///
/// final onDocumentFile = listFiles(myUri, [DocumentFileColumn.id]);
///
/// onDocumentFile.listen((document) {
///   myState.add(document);
///
///   final documentId = document.data?[DocumentFileColumn.id]
///
///   print('$documentId was added to state');
/// });
/// ```
Stream<PartialDocumentFile> listFiles(
    {required Uri uri, required List<DocumentFileColumn> columns}) {
  const kListFiles = 'listFiles';

  const kUri = 'uri';
  const kEvent = 'event';
  const kColumns = 'columns';

  final args = <String, dynamic>{
    kUri: '$uri',
    kEvent: kListFiles,
    kColumns: columns.map((e) => '$e').toList(),
  };

  final onCursorRowResult =
      kDocumentFileEventChannel.receiveBroadcastStream(args);

  return onCursorRowResult
      .map((e) => PartialDocumentFile.fromMap(Map.from(e)))
      .cast<PartialDocumentFile>();
}

/// Verify if a given [uri] exists
Future<bool?> exists(Uri uri) async {
  const kExists = 'exists';

  const kUri = 'uri';

  final args = {kUri: uri};

  return await kDocumentFileChannel.invokeMethod<bool>(kExists, args);
}

/// Equivalent to `DocumentsContract.buildDocumentUriUsingTree`
///
/// [Refer to details](https://developer.android.com/reference/android/provider/DocumentsContract#buildDocumentUriUsingTree(android.net.Uri,%20java.lang.String))
Future<Uri?> buildDocumentUriUsingTree(Uri treeUri, String documentId) async {
  const kBuildDocumentUriUsingTree = 'buildDocumentUriUsingTree';

  const kTreeUri = 'treeUri';
  const kDocumentId = 'documentId';

  final args = <String, String>{
    kTreeUri: '$treeUri',
    kDocumentId: documentId,
  };

  final uri = await kDocumentsContractChannel.invokeMethod<String>(
      kBuildDocumentUriUsingTree, args);

  if (uri == null) return null;

  return Uri.parse(uri);
}

/// Equivalent to `DocumentsContract.buildDocumentUri`
///
/// [Refer to details](https://developer.android.com/reference/android/provider/DocumentsContract#buildDocumentUri(java.lang.String,%20java.lang.String))
Future<Uri?> buildDocumentUri(String authority, String documentId) async {
  const kBuildDocumentUri = 'buildDocumentUri';

  const kAuthority = 'authority';
  const kDocumentId = 'documentId';

  final args = <String, String>{
    kAuthority: authority,
    kDocumentId: documentId,
  };

  final uri = await kDocumentsContractChannel.invokeMethod<String>(
      kBuildDocumentUri, args);

  if (uri == null) return null;

  return Uri.parse(uri);
}

/// Equivalent to `DocumentsContract.buildDocumentUri`
///
/// [Refer to details](https://developer.android.com/reference/android/provider/DocumentsContract#buildDocumentUri(java.lang.String,%20java.lang.String))
Future<Uri?> buildTreeDocumentUri(String authority, String documentId) async {
  const kBuildTreeDocumentUri = 'buildTreeDocumentUri';

  const kAuthority = 'authority';
  const kDocumentId = 'documentId';

  final args = <String, String>{
    kAuthority: authority,
    kDocumentId: documentId,
  };

  final uri = await kDocumentsContractChannel.invokeMethod<String>(
      kBuildTreeDocumentUri, args);

  if (uri == null) return null;

  return Uri.parse(uri);
}
