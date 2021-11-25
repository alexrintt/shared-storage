import 'package:shared_storage/shared_storage.dart';
import 'package:shared_storage/src/method_channel.dart';
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
Future<Uri?> openDocumentTree() async {
  const kOpenDocumentTree = 'openDocumentTree';

  final selectedDirectoryUri =
      await kChannel.invokeMethod<String?>(kOpenDocumentTree);

  if (selectedDirectoryUri == null) return null;

  return Uri.parse(selectedDirectoryUri);
}

/// Starts Activity Action: Allow the user to create a new document.
/// When invoked, the system will display the various `DocumentsProvider`
/// instances installed on the device, letting the user navigate through them.
/// The returned document may be a newly created document with no content,
/// or it may be an existing document with the requested MIME type.
///
/// - [mimeType] is the kind of file that you want to create
/// - [content] the file content, will be converted to bytes `List<Int>`
/// - [displayName] the name of the file without any extension
/// - [directory] Needs to be the [URI] directory returned by `openDocumentTree`
///
/// [Refer to details](https://developer.android.com/reference/android/content/Intent#ACTION_CREATE_DOCUMENT)
Future<Uri?> createDocumentFile({
  required String mimeType,
  required String content,
  required String displayName,
  required Uri directory,
}) async {
  const kCreateDocumentFile = 'createDocumentFile';

  const kMimeTypeArg = 'mimeType';
  const kContentArg = 'content';
  const kDisplayNameArg = 'displayName';
  const kDirectoryUriArg = 'directoryUri';

  final directoryUri = '$directory';

  final args = <String, String>{
    kMimeTypeArg: mimeType,
    kContentArg: content,
    kDisplayNameArg: displayName,
    kDirectoryUriArg: directoryUri,
  };

  final createdFileUri =
      await kChannel.invokeMethod<String?>(kCreateDocumentFile, args);

  if (createdFileUri == null) return null;

  return Uri.parse(createdFileUri);
}

/// Returns an `List<URI>` with all persisted [URI]
///
/// To persist an [URI] call `openDocumentTree`
/// and to remove an persisted [URI] call `releasePersistableUriPermission`
Future<List<UriPermission>?> persistedUriPermissions() async {
  const kPersistedUriPermissions = 'persistedUriPermissions';

  final persistedUriPermissions =
      await kChannel.invokeListMethod(kPersistedUriPermissions);

  if (persistedUriPermissions == null) return null;

  return persistedUriPermissions
      .map((internalHashMap) => UriPermission.fromMap(
          Map.from(internalHashMap).cast<String, dynamic>()))
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

  const kDirectoryUri = 'directoryUri';

  final args = <String, String>{kDirectoryUri: '$directory'};

  await kChannel.invokeMethod(kReleasePersistableUriPermission, args);
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
