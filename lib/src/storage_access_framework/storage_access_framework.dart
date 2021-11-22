import 'package:shared_storage/shared_storage.dart';
import 'package:shared_storage/src/method_channel.dart';
import 'package:shared_storage/src/storage_access_framework/uri_permission.dart';

/// TODO: Add [initialDir] param as mentioned here:
/// TODO: Add documentation
Future<Uri?> openDocumentTree() async {
  const kOpenDocumentTree = 'openDocumentTree';

  final selectedDirectoryUri =
      await kChannel.invokeMethod<String?>(kOpenDocumentTree);

  if (selectedDirectoryUri == null) return null;

  return Uri.parse(selectedDirectoryUri);
}

/// TODO: Add documentation
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

Future<void> releasePersistableUriPermission(Uri directory) async {
  const kReleasePersistableUriPermission = 'releasePersistableUriPermission';

  const kDirectoryUri = 'directoryUri';

  final args = <String, String>{kDirectoryUri: '$directory'};

  await kChannel.invokeMethod(kReleasePersistableUriPermission, args);
}

/// Convenient method to verify if a given [uri]
/// is allowed to be write or read from SAF API's
///
/// TODO: Improve documentation
Future<bool> isPersistedUri(Uri uri) async {
  final persistedUris = await persistedUriPermissions();

  return persistedUris?.any((persistedUri) => persistedUri.uri == uri) ?? false;
}
