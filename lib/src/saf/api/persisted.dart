import '../../channels.dart';
import '../../common/functional_extender.dart';
import '../models/barrel.dart';

/// {@template sharedstorage.saf.persistedUriPermissions}
/// Returns an `List<Uri>` with all persisted [Uri]
///
/// To persist an [Uri] call `openDocumentTree`.
///
/// To remove an persisted [Uri] call `releasePersistableUriPermission`.
/// {@endtemplate}
Future<List<UriPermission>?> persistedUriPermissions() async {
  final List<dynamic>? persistedUriPermissions =
      await kDocumentFileChannel.invokeListMethod('persistedUriPermissions');

  return persistedUriPermissions?.apply(
    (List<dynamic> p) => p
        .map(
          (dynamic e) => UriPermission.fromMap(
            Map<String, dynamic>.from(
              e as Map<String, dynamic>,
            ),
          ),
        )
        .toList(),
  );
}

/// {@template sharedstorage.saf.isPersistedUri}
/// Convenient method to verify if a given [uri].
/// is allowed to be write or read from SAF API's.
///
/// This uses the `releasePersistableUriPermission` method to get the List
/// of allowed [Uri]s then will verify if the [uri] is included in.
/// {@endtemplate}
Future<bool> isPersistedUri(Uri uri) async {
  final List<UriPermission>? persistedUris = await persistedUriPermissions();

  return persistedUris
          ?.any((UriPermission persistedUri) => persistedUri.uri == uri) ??
      false;
}

/// {@template sharedstorage.saf.releasePersistableUriPermission}
/// Will revoke an persistable Uri.
///
/// Call this when your App no longer wants the permission of an [Uri] returned
/// by `openDocumentTree` method.
///
/// To get the current persisted [Uri]s call `persistedUriPermissions`.
///
/// [Refer to details](https://developer.android.com/reference/android/content/ContentResolver#releasePersistableUriPermission(android.net.Uri,%20int)).
/// {@endtemplate}
Future<void> releasePersistableUriPermission(Uri directory) async {
  await kDocumentFileChannel.invokeMethod(
    'releasePersistableUriPermission',
    <String, String>{'uri': '$directory'},
  );
}
