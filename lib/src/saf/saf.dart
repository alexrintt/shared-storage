import 'dart:async';
import 'dart:typed_data';

import '../../saf.dart';
import '../channels.dart';
import 'common.dart';

/// {@template sharedstorage.saf.openDocumentTree}
/// Start Activity Action: Allow the user to pick a directory subtree.
/// When invoked, the system will display the various `DocumentsProvider`
/// instances installed on the device, letting the user navigate through them.
/// Apps can fully manage documents within the returned directory.
///
/// [Refer to details](https://developer.android.com/reference/android/content/Intent#ACTION_OPEN_DOCUMENT_TREE)
///
/// support the initial directory of the directory picker
/// {@endtemplate}
Future<Uri?> openDocumentTree({
  bool grantWritePermission = true,
  Uri? initialUri,
}) async {
  const kOpenDocumentTree = 'openDocumentTree';

  final args = <String, dynamic>{
    'grantWritePermission': grantWritePermission,
    if (initialUri != null) 'initialUri': '$initialUri',
  };

  final selectedDirectoryUri =
      await kDocumentFileChannel.invokeMethod<String?>(kOpenDocumentTree, args);

  if (selectedDirectoryUri == null) return null;

  return Uri.parse(selectedDirectoryUri);
}

/// {@template sharedstorage.saf.persistedUriPermissions}
/// Returns an `List<Uri>` with all persisted [Uri]
///
/// To persist an [Uri] call `openDocumentTree`
/// and to remove an persisted [Uri] call `releasePersistableUriPermission`
/// {@endtemplate}
Future<List<UriPermission>?> persistedUriPermissions() async {
  const kPersistedUriPermissions = 'persistedUriPermissions';

  final persistedUriPermissions =
      await kDocumentFileChannel.invokeListMethod(kPersistedUriPermissions);

  if (persistedUriPermissions == null) return null;

  return persistedUriPermissions
      .map((e) => UriPermission.fromMap(Map.from(e as Map)))
      .toList();
}

/// {@template sharedstorage.saf.releasePersistableUriPermission}
/// Will revoke an persistable Uri
///
/// Call this when your App no longer wants the permission of an [Uri] returned
/// by `openDocumentTree` method
///
/// To get the current persisted [Uri]s call `persistedUriPermissions`
/// {@endtemplate}
Future<void> releasePersistableUriPermission(Uri directory) async {
  const kReleasePersistableUriPermission = 'releasePersistableUriPermission';

  final args = <String, String>{'uri': '$directory'};

  await kDocumentFileChannel.invokeMethod(
    kReleasePersistableUriPermission,
    args,
  );
}

/// {@template sharedstorage.saf.isPersistedUri}
/// Convenient method to verify if a given [uri]
/// is allowed to be write or read from SAF API's
///
/// This uses the `releasePersistableUriPermission` method to get the List
/// of allowed [Uri]s then will verify if the [uri] is included in
/// {@endtemplate}
Future<bool> isPersistedUri(Uri uri) async {
  final persistedUris = await persistedUriPermissions();

  return persistedUris?.any((persistedUri) => persistedUri.uri == uri) ?? false;
}

/// {@template sharedstorage.saf.canRead}
/// Equivalent to `DocumentFile.canRead`
///
/// [Refer to details](https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#canRead())
/// {@endtemplate}
Future<bool?> canRead(Uri uri) async {
  const kCanRead = 'canRead';

  final args = {'uri': '$uri'};

  return kDocumentFileChannel.invokeMethod<bool>(kCanRead, args);
}

/// {@template sharedstorage.saf.canWrite}
/// Equivalent to `DocumentFile.canWrite`
///
/// [Refer to details](https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#canWrite())
/// {@endtemplate}
Future<bool?> canWrite(Uri uri) async {
  const kCanWrite = 'canWrite';

  final args = {'uri': '$uri'};

  return kDocumentFileChannel.invokeMethod<bool>(kCanWrite, args);
}

/// {@template sharedstorage.saf.getDocumentThumbnail}
/// Equivalent to `DocumentsContract.getDocumentThumbnail`
///
/// [Refer to details](https://developer.android.com/reference/android/provider/DocumentsContract#getDocumentThumbnail(android.content.ContentResolver,%20android.net.Uri,%20android.graphics.Point,%20android.os.CancellationSignal))
/// {@endtemplate}
Future<DocumentBitmap?> getDocumentThumbnail({
  required Uri rootUri,
  required String documentId,
  required double width,
  required double height,
}) async {
  const kGetDocumentThumbnail = 'getDocumentThumbnail';

  final args = <String, dynamic>{
    'rootUri': '$rootUri',
    'documentId': documentId,
    'width': width,
    'height': height,
  };

  final bitmap = await kDocumentsContractChannel
      .invokeMapMethod<String, dynamic>(kGetDocumentThumbnail, args);

  if (bitmap == null) return null;

  return DocumentBitmap.fromMap(bitmap);
}

/// {@template sharedstorage.saf.listFiles}
/// **Important**: Ensure you have read permission by calling `canRead` before calling `listFiles`
///
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
///
/// [Refer to details](https://stackoverflow.com/questions/41096332/issues-traversing-through-directory-hierarchy-with-android-storage-access-framew)
/// {@endtemplate}
Stream<PartialDocumentFile> listFiles(
  Uri uri, {
  required List<DocumentFileColumn> columns,
}) {
  const kListFiles = 'listFiles';

  final args = <String, dynamic>{
    'uri': '$uri',
    'event': kListFiles,
    'columns': columns.map((e) => '$e').toList(),
  };

  final onCursorRowResult =
      kDocumentFileEventChannel.receiveBroadcastStream(args);

  return onCursorRowResult
      .map((e) => PartialDocumentFile.fromMap(Map.from(e as Map)))
      .cast<PartialDocumentFile>();
}

/// {@template sharedstorage.saf.exists}
/// Verify if a given [uri] exists
/// {@endtemplate}
Future<bool?> exists(Uri uri) async {
  const kExists = 'exists';

  final args = <String, String>{'uri': '$uri'};

  return kDocumentFileChannel.invokeMethod<bool>(kExists, args);
}

/// {@template sharedstorage.saf.buildDocumentUriUsingTree}
/// Equivalent to `DocumentsContract.buildDocumentUriUsingTree`
///
/// [Refer to details](https://developer.android.com/reference/android/provider/DocumentsContract#buildDocumentUriUsingTree%28android.net.Uri,%20java.lang.String%29)
/// {@endtemplate}
Future<Uri?> buildDocumentUriUsingTree(Uri treeUri, String documentId) async {
  const kBuildDocumentUriUsingTree = 'buildDocumentUriUsingTree';

  final args = <String, String>{
    'treeUri': '$treeUri',
    'documentId': documentId,
  };

  final uri = await kDocumentsContractChannel.invokeMethod<String>(
    kBuildDocumentUriUsingTree,
    args,
  );

  if (uri == null) return null;

  return Uri.parse(uri);
}

/// {@template sharedstorage.saf.buildDocumentUri}
/// Equivalent to `DocumentsContract.buildDocumentUri`
///
/// [Refer to details](https://developer.android.com/reference/android/provider/DocumentsContract#buildDocumentUri%28java.lang.String,%20java.lang.String%29)
/// {@endtemplate}
Future<Uri?> buildDocumentUri(String authority, String documentId) async {
  const kBuildDocumentUri = 'buildDocumentUri';

  final args = <String, String>{
    'authority': authority,
    'documentId': documentId,
  };

  final uri = await kDocumentsContractChannel.invokeMethod<String>(
    kBuildDocumentUri,
    args,
  );

  if (uri == null) return null;

  return Uri.parse(uri);
}

/// {@template sharedstorage.saf.buildDocumentUri}
/// Equivalent to `DocumentsContract.buildDocumentUri`
///
/// [Refer to details](https://developer.android.com/reference/android/provider/DocumentsContract#buildDocumentUri%28java.lang.String,%20java.lang.String%29)
/// {@endtemplate}
Future<Uri?> buildTreeDocumentUri(String authority, String documentId) async {
  const kBuildTreeDocumentUri = 'buildTreeDocumentUri';

  final args = <String, String>{
    'authority': authority,
    'documentId': documentId,
  };

  final uri = await kDocumentsContractChannel.invokeMethod<String>(
    kBuildTreeDocumentUri,
    args,
  );

  if (uri == null) return null;

  return Uri.parse(uri);
}

/// {@template sharedstorage.saf.delete}
/// Equivalent to `DocumentFile.delete`
///
/// Returns `true` if deleted successfully
///
/// [Refer to details](https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#delete%28%29)
/// {@endtemplate}
Future<bool?> delete(Uri uri) async {
  const kDelete = 'delete';

  final args = <String, String>{'uri': '$uri'};

  return kDocumentFileChannel.invokeMethod<bool>(kDelete, args);
}

/// {@template sharedstorage.saf.createDirectory}
/// Create a direct child document tree named `displayName` given a parent `parentUri`
///
/// Equivalent to `DocumentFile.createDirectory`
///
/// [Refer to details](https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#createDirectory%28java.lang.String%29)
/// {@endtemplate}
Future<DocumentFile?> createDirectory(Uri parentUri, String displayName) async {
  const kCreateDirectory = 'createDirectory';

  final args = <String, String>{
    'uri': '$parentUri',
    'displayName': displayName,
  };

  final createdDocumentFile = await kDocumentFileChannel
      .invokeMapMethod<String, dynamic>(kCreateDirectory, args);

  if (createdDocumentFile == null) return null;

  return DocumentFile.fromMap(createdDocumentFile);
}

/// {@template sharedstorage.saf.createFile}
/// Convenient method to create files using either String or raw bytes
///
/// Under the hood this method calls `createFileAsString` or `createFileAsBytes`
/// depending on which argument is passed
///
/// If both (bytes and content) are passed, the bytes will be used and the content will be ignored
/// {@endtemplate}
Future<DocumentFile?> createFile(
  Uri parentUri, {
  required String mimeType,
  required String displayName,
  Uint8List? bytes,
  String? content,
}) {
  assert(
    bytes != null || content != null,
    '''Either [bytes] or [content] should be provided''',
  );

  return bytes != null
      ? createFileAsBytes(
          parentUri,
          mimeType: mimeType,
          displayName: displayName,
          bytes: bytes,
        )
      : createFileAsString(
          parentUri,
          mimeType: mimeType,
          displayName: displayName,
          content: content!,
        );
}

/// {@template sharedstorage.saf.createFileAsBytes}
/// Create a direct child document of `parentUri`
/// - `mimeType` is the type of document following [this specs](https://www.iana.org/assignments/media-types/media-types.xhtml)
/// - `displayName` is the name of the document, must be a valid file name
/// - `bytes` is the content of the document as a list of bytes `Uint8List`
///
/// Returns the created file as a `DocumentFile`
/// {@endtemplate}
Future<DocumentFile?> createFileAsBytes(
  Uri parentUri, {
  required String mimeType,
  required String displayName,
  required Uint8List bytes,
}) async {
  const kCreateFile = 'createFile';

  final directoryUri = '$parentUri';

  final args = <String, dynamic>{
    'mimeType': mimeType,
    'content': bytes,
    'displayName': displayName,
    'directoryUri': directoryUri,
  };

  return invokeMapMethod(kCreateFile, args);
}

/// {@template sharedstorage.saf.createFileAsString}
/// Convenient method to create a file
/// using `content` as String instead Uint8List
/// {@endtemplate}
Future<DocumentFile?> createFileAsString(
  Uri parentUri, {
  required String mimeType,
  required String displayName,
  required String content,
}) {
  return createFileAsBytes(
    parentUri,
    displayName: displayName,
    mimeType: mimeType,
    bytes: Uint8List.fromList(content.codeUnits),
  );
}

/// {@template sharedstorage.saf.length}
/// Equivalent to `DocumentFile.length`
///
/// Returns the size of a given document `uri` in bytes
///
/// [Refer to details](https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#length%28%29)
/// {@endtemplate}
Future<int?> documentLength(Uri uri) async {
  const kLength = 'length';

  final args = <String, String>{'uri': '$uri'};

  return kDocumentFileChannel.invokeMethod<int>(kLength, args);
}

/// {@template sharedstorage.saf.lastModified}
/// Equivalent to `DocumentFile.lastModified`
///
/// [Refer to details](https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#lastModified%28%29)
/// {@endtemplate}
Future<DateTime?> lastModified(Uri uri) async {
  const kLastModified = 'lastModified';

  final args = <String, String>{'uri': '$uri'};

  final inMillisecondsSinceEpoch =
      await kDocumentFileChannel.invokeMethod<int>(kLastModified, args);

  if (inMillisecondsSinceEpoch == null) return null;

  return DateTime.fromMillisecondsSinceEpoch(inMillisecondsSinceEpoch);
}

/// {@template sharedstorage.saf.findFile}
/// Equivalent to `DocumentFile.findFile`
///
/// If you want to check if a given document file exists by their [displayName] prefer using `child` instead
///
/// [Refer to details](https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#findFile%28java.lang.String%29)
/// {@endtemplate}
Future<DocumentFile?> findFile(Uri directoryUri, String displayName) async {
  const kFindFile = 'findFile';

  final args = <String, String>{
    'uri': '$directoryUri',
    'displayName': displayName,
  };

  return invokeMapMethod(kFindFile, args);
}

/// {@template sharedstorage.saf.renameTo}
/// Rename the current document `uri` to a new `displayName`
///
/// **Note: after using this method `uri` is not longer valid,
/// use the returned document instead**
///
/// Returns the updated document
///
/// Equivalent to `DocumentFile.renameTo`
///
/// [Refer to details](https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#renameTo%28java.lang.String%29)
/// {@endtemplate}
Future<DocumentFile?> renameTo(Uri uri, String displayName) async {
  const kRenameTo = 'renameTo';

  final args = <String, String>{'uri': '$uri', 'displayName': displayName};

  return invokeMapMethod(kRenameTo, args);
}

/// {@template sharedstorage.saf.fromTreeUri}
/// Create a new `DocumentFile` instance given `uri`
///
/// Equivalent to `DocumentFile.fromTreeUri`
///
/// [Refer to details](https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#fromTreeUri%28android.content.Context,%20android.net.Uri%29)
/// {@endtemplate}
Future<DocumentFile?> fromTreeUri(Uri uri) async {
  const kFromTreeUri = 'fromTreeUri';

  final args = <String, String>{'uri': '$uri'};

  return invokeMapMethod(kFromTreeUri, args);
}

/// {@template sharedstorage.saf.child}
/// Return the `child` of the given `uri` if it exists otherwise `null`
///
/// It's faster than [DocumentFile.findFile]
/// `path` is the single file name or file path. Empty string returns to itself.
///
/// Equivalent to `DocumentFile.child` extension/overload
///
/// [Refer to details](https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#fromTreeUri%28android.content.Context,%20android.net.Uri%29)
/// {@endtemplate}
Future<DocumentFile?> child(
  Uri uri,
  String path, {
  bool requiresWriteAccess = false,
}) async {
  const kChild = 'child';

  final args = <String, dynamic>{
    'uri': '$uri',
    'path': path,
    'requiresWriteAccess': requiresWriteAccess,
  };

  return invokeMapMethod(kChild, args);
}

/// {@template sharedstorage.saf.openDocumentFile}
/// It's a convenience method to launch the default application associated with the given MIME type
/// and can't be considered an official SAF API.
///
/// Launch `ACTION_VIEW` intent to open the given document `uri`
///
/// Throws an `PlatformException` with code `EXCEPTION_ACTIVITY_NOT_FOUND` if the activity is not found
/// to the respective MIME type of the give Uri.
///
/// Returns `true` if launched successfully otherwise `false`
/// {@endtemplate}
Future<bool?> openDocumentFile(Uri uri) async {
  const kOpenDocumentFile = 'openDocumentFile';

  final args = <String, String>{'uri': '$uri'};

  final launched = await kDocumentFileHelperChannel.invokeMethod<bool>(
    kOpenDocumentFile,
    args,
  );

  return launched;
}

/// {@template sharedstorage.saf.parentFile}
/// Get the parent file of the given `uri`
///
/// Equivalent to `DocumentFile.getParentFile`
///
/// [Refer to details](https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#getParentFile%28%29)
/// {@endtemplate}
Future<DocumentFile?> parentFile(Uri uri) async {
  const kParentFile = 'parentFile';

  final args = <String, String>{'uri': '$uri'};

  return invokeMapMethod(kParentFile, args);
}

/// {@template sharedstorage.saf.copy}
/// Copy a document `uri` to the `destination`
///
/// This API uses the `createFile` and `getDocumentContent` API's behind the scenes
/// {@endtemplate}
Future<DocumentFile?> copy(Uri uri, Uri destination) async {
  const kCopy = 'copy';

  final args = <String, String>{'uri': '$uri', 'destination': '$destination'};

  return invokeMapMethod(kCopy, args);
}

/// {@template sharedstorage.saf.getDocumentContent}
/// Get content of a given document `uri`
///
/// Equivalent to `contentDescriptor` usage
///
/// [Refer to details](https://developer.android.com/training/data-storage/shared/documents-files#input_stream)
/// {@endtemplate}
Future<Uint8List?> getDocumentContent(Uri uri) async {
  const kGetDocumentContent = 'getDocumentContent';

  final args = <String, String>{'uri': '$uri'};

  return kDocumentFileChannel.invokeMethod<Uint8List>(
    kGetDocumentContent,
    args,
  );
}

/// {@template sharedstorage.saf.getDocumentContentAsString}
/// Helper method to read document using
/// `getDocumentContent` and get the content as String instead as `Uint8List`
/// {@endtemplate}
Future<String?> getDocumentContentAsString(
  Uri uri, {
  bool throwIfError = false,
}) async {
  final bytes = await getDocumentContent(uri);

  if (bytes == null) return null;

  return String.fromCharCodes(bytes);
}

/// {@template sharedstorage.saf.getDocumentContentAsString}
/// Helper method to generate the file path of the given `uri`
///
/// See [Get real path from URI, Android KitKat new storage access framework](https://stackoverflow.com/questions/20067508/get-real-path-from-uri-android-kitkat-new-storage-access-framework/20559175#20559175)
/// for details
/// {@endtemplate}
Future<String?> getRealPathFromUri(Uri uri) async {
  const kGetRealPathFromUri = 'getRealPathFromUri';

  final args = <String, String>{'uri': '$uri'};

  return kDocumentFileHelperChannel.invokeMethod(kGetRealPathFromUri, args);
}
