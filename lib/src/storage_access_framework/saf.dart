import 'package:shared_storage/shared_storage.dart';
import 'package:shared_storage/src/channels.dart';
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
