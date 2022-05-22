## Import package

```dart
import 'package:shared_storage/saf.dart' as saf;
```

> **Note** Be aware that if you import the package `import '...' as saf;` (strongly recommended) you should prefix all method calls with `saf`, example:

```dart
saf.openDocumentTree(...);
saf.listFiles(...);
```

But if you import without alias `import '...';` (Not recommeded because can conflict with other method/package names) you should use directly as functions:

```dart
openDocumentTree(...);
listFiles(...);
```

## Example project

The example project does use of most of these APIs, that is available at [`/example`](https://github.com/lakscastro/shared-storage/tree/master/example)

## Concepts

This is a brief explanation of the core concepts of this API.

### What's an `Uri`?

`Uri` is a the most confusing concept we can found. Since it's not a regular string, it's not a regular url, neither a regular file system path.

By the [official docs](https://developer.android.com/reference/java/net/URI#uris,-urls,-and-urns):

> A URI is a uniform resource identifier while a URL is a uniform resource locator. Hence every URL is a URI, abstractly speaking, but not every URI is a URL. This is because there is another subcategory of URIs, uniform resource names (URNs), which name resources but do not specify how to locate them. The mailto, news, and isbn URIs shown above are examples of URNs.

Which translated means: this `Uri` **can represent** almost anything.

Often this `Uri`s represent a folder or a file but not always. And different `Uri`s can point to the same file/folder

### Permission over an `Uri`

To operate (read, delete, update, create) a file or folder within a directory, you need first to request permission of the user. These permissions are represented as `UriPermission`, [reference](https://developer.android.com/reference/android/content/UriPermission).

## API reference

Orignal API. These methods exists only in this package.

Because methods are an abstraction from native API, for example: `openDocumentTree` is an abstraction because there's no such method in native Android, there you need to create a intent and start an activity which is not the goal of this package (re-create all Android APIs) but provide a powerful fully-configurable API to call these APIs.

### <samp>openDocumentTree</samp>

This API allows you grant `Uri`s permission by calling like this:

```dart
final Uri? grantedUri = await openDocumentTree();

if (grantedUri != null) {
  print('Now I have permission over this Uri: $grantedUri');
}
```

### <samp>listFiles</samp>

This method list files lazily **over a granted uri:**

```dart
/// *Must* be a granted uri from `openDocumentTree`
final Uri myGrantedUri = ...
final DocumentFile? documentFileOfMyGrantedUri = await myGrantedUri.toDocumentFile();

if (documentFileOfMyGrantedUri == null) {
  return print('This is not a valid Uri permission or you do not have the permission');
}

/// Columns/Fields you want access. Android handle storage as database.
/// Allow you specify only the fields you need to use, avoiding querying unnecessary data
const columns = [
  DocumentFileColumn.displayName,
  DocumentFileColumn.size,
  DocumentFileColumn.lastModified,
  DocumentFileColumn.id,
  DocumentFileColumn.mimeType,
];

final List<PartialDocumentFile> files = [];

final Stream<PartialDocumentFile> onNewFileLoaded = documentFileOfMyGrantedUri.listFiles(columns);

onNewFileLoaded.listen((file) => files.add(file), onDone: () => print('All files were loaded'));
```

## Mirror methods

Mirror methods are available to provide an way to call a native method without using any abstraction, available mirror methods:

### <samp>persistedUriPermissions</samp>

Mirror of [`ContentResolver.getPersistedUriPermissions`](<https://developer.android.com/reference/android/content/ContentResolver#getPersistedUriPermissions()>)

Basically this allow get the **granted** `Uri`s permissions after the app restarts without the need of requesting the folders again.

```dart
final List<UriPermission>? grantedUris = await persistedUriPermissions();

if (grantedUris != null) {
  print('There is no granted Uris');
} else {
  print('My granted Uris: $grantedUris');
}
```

From the official docs:

> Return list of all URI permission grants that have been persisted by the calling app. That is, the returned permissions have been granted to the calling app. Only persistable grants taken with `takePersistableUriPermission(android.net.Uri, int)` are returned.
> Note: Some of the returned URIs may not be usable until after the user is unlocked.

### <samp>releasePersistableUriPermission</samp>

<samp>Mirror of [`ContentResolver.releasePersistableUriPermission`](<https://developer.android.com/reference/android/content/ContentResolver#releasePersistableUriPermission(android.net.Uri,%20int)>)</samp>

Opposite of `openDocumentTree`. This method revoke all permissions you have under a specific `Uri`. This should be used to allow the user revoke the permission of `Uri`s inside your app without needing revoking at OS level.

```dart
final List<UriPermission> grantedUris = ...

/// Revoke all granted Uris
for (final UriPermission uri of grantedUris) {
  await releasePersistableUriPermission(uri);
}

/// You can also revoke a single Uri
await releasePersistableUriPermission(grantedUris[0]);
```

## Alias methods

These APIs are only shortcuts/alias, that is, they do not call native code directly, these are just convenient methods.

### <samp>isPersistedUri</samp>

<samp>Alias for `persistedUriPermissions`</samp>

Check if a given `Uri` is persisted/granted, that is, you have permission over it.

```dart
/// Can be any Uri
final Uri maybeGrantedUri = ...

final bool ensureThisIsGrantedUri = await isPersistedUri(maybeGrantedUri);

if (ensureThisIsGrantedUri) {
  print('I have permission over the Uri: $maybeGrantedUri');
}
```

Alias implementation:

```dart
Future<bool> isPersistedUri(Uri uri) async {
  final List<UriPermission>? persistedUris = await persistedUriPermissions();

  return persistedUris?.any((persistedUri) => persistedUri.uri == uri) ?? false;
}
```

## Android Official Documentation

The **Storage Access Framework** [official documentation is available here.](https://developer.android.com/guide/topics/providers/document-provider)

All the APIs listed in this plugin module are derivated from the official docs.
