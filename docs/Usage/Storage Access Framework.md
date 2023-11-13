## Import package

```dart
import 'package:shared_storage/shared_storage.dart' as saf;
```

Usage sample:

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

The example project does use of most of these APIs, that is available at [`/example`](https://github.com/alexrintt/shared-storage/tree/master/example)

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

## API Labeling

See the label [reference here](../Usage/API%20Labeling.md).

## API reference

Original API. These methods exists only in this package.

Because methods are an abstraction from native API, for example: `openDocumentTree` is an abstraction because there's no such method in native Android, there you need to create a intent and start an activity which is not the goal of this package (re-create all Android APIs) but provide a powerful fully-configurable API to call these APIs.

### <samp>openDocumentTree</samp>

This API allows you grant `Uri`s permission by calling like this:

```dart
final Uri? grantedUri = await openDocumentTree();

if (grantedUri != null) {
  print('Now I have permission over this Uri: $grantedUri');
}
```

### <samp>openDocument</samp>

Same as `openDocumentTree` but for file URIs, you can request user to select a file and filter by:

- Single or multiple files.
- Mime type.

You can also specify if you want a one-time operation (`persistablePermission` = false) and if you don't need write access (`grantWritePermission` = false).

```dart
const kDownloadsFolder =
    'content://com.android.externalstorage.documents/tree/primary%3ADownloads/document/primary%3ADownloads';

final List<Uri>? selectedDocumentUris = await openDocument(
  // if you have a previously saved URI,
  // you can use the specify the tree you user will see at startup of the file picker.
  initialUri: Uri.parse(kDownloadsFolder),

  // whether or not allow the user select multiple files.
  multiple: true,

  // whether or not the selected URIs should be persisted across app and device reboots.
  persistablePermission: true,

  // whether or not grant write permission required to edit file metadata (name) and it's contents.
  grantWritePermission: true,

  // whether or not filter by mime type.
  mimeType: 'image/*' // default '*/*'
);

if (selectedDocumentUris == null) {
  return print('User cancelled the operation.');
}

// If [selectedDocumentUris] are [persistablePermission]s then it will be returned by this function
// along with any another URIs you've got permission over.
final List<UriPermission> persistedUris = await persistedUriPermissions();
```

### <samp>listFiles</samp>

This method list files lazily **over a granted uri:**

> **Note** `DocumentFileColumn.id` is optional. It is required to fetch the file list from native API. So it is enabled regardless if you include this column or not. And this applies only to this API (`listFiles`).

```dart
/// *Must* be a granted uri from `openDocumentTree`, or a URI representing a child under such a granted uri.
final Uri myGrantedUri = ...
final DocumentFile? documentFileOfMyGrantedUri = await myGrantedUri.toDocumentFile();

if (documentFileOfMyGrantedUri == null) {
  return print('This is not a valid Uri permission or you do not have the permission');
}

/// Columns/Fields you want access. Android handle storage as database.
/// Allow you specify only the fields you need to use, avoiding querying unnecessary data
const List<DocumentFileColumn> columns = <DocumentFileColumn>[
  DocumentFileColumn.displayName,
  DocumentFileColumn.size,
  DocumentFileColumn.lastModified,
  DocumentFileColumn.id, // Optional column, will be available/queried regardless if is or not included here
  DocumentFileColumn.mimeType,
];

final List<DocumentFile> files = [];

final Stream<DocumentFile> onNewFileLoaded = documentFileOfMyGrantedUri.listFiles(columns);

onNewFileLoaded.listen((file) => files.add(file), onDone: () => print('All files were loaded'));
```

### <samp>openDocumentFile</samp>

Open a file uri in a external app, by starting a new activity with `ACTION_VIEW` Intent.

```dart
final Uri fileUri = ...

/// This call will prompt the user: "Open with" dialog
/// Or will open directly in the app if this there's only a single app that can handle this file type.
await openDocumentFile(fileUri);
```

### <samp>getDocumentContent</samp>

Read a document file from its uri by opening a input stream and returning its bytes.

```dart
/// See also: [getDocumentContentAsString]
final Uri uri = ...

final Uint8List? fileContent = await getDocumentContent(uri);

/// Handle [fileContent]...

/// If the file is intended to be human readable, you can convert the output to [String]:
print(utf8.decode(fileContent));
```

### <samp>getRealPathFromUri</samp>

Helper method to generate the file path of the given `uri`. This returns the real path to work with native old `File` API instead Uris, be aware this approach is no longer supported on Android 10+ (API 29+) and though new, this API is **marked as deprecated** and should be migrated to a _scoped-storage_ approach.

See [Get real path from URI, Android KitKat new storage access framework](https://stackoverflow.com/questions/20067508/get-real-path-from-uri-android-kitkat-new-storage-access-framework/20559175#20559175) for details.

```dart
final Uri uri = ...;

final String? filePath = await getRealPathFromUri(myUri);

final File file = File(filePath);
```

## Mirror methods

Mirror methods are available to provide an way to call a native method without using any abstraction, available mirror methods:

### <samp>exists</samp>

Mirror of [`DocumentFile.exists`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#exists()>)

Returns `true` if a given `uri` exists.

```dart
final Uri uri = ...

if (await exists(uri) ?? false) {
  print('There is no granted Uris');
} else {
  print('My granted Uris: $grantedUris');
}
```

### <samp>persistedUriPermissions</samp>

Mirror of [`ContentResolver.getPersistedUriPermissions`](<https://developer.android.com/reference/android/content/ContentResolver#getPersistedUriPermissions()>)

Basically this allow get the **granted** `Uri`s permissions after the app restarts without the need of requesting the folders again.

```dart
final List<UriPermission>? grantedUris = await persistedUriPermissions();

if (grantedUris == null) {
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

### <samp>createFileAsBytes</samp>

<samp>Mirror of [`DocumentFile.createFile`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#createFile(java.lang.String,%20java.lang.String)>)</samp>

Create a file using raw bytes `Uint8List`.

Given the parent uri, creates a new child document file that represents a single file given the `displayName`, `mimeType` and its `content` in bytes (file name, file type and file content in raw bytes, respectively).

```dart
final Uri parentUri = ...
final String fileContent = 'My File Content';

final DocumentFile? createdFile = createFileAsBytes(
  parentUri,
  mimeType: 'text/plain',
  displayName: 'Sample File Name',
  bytes: Uint8List.fromList(utf8.encode(fileContent)),
);
```

### <samp>writeToFileAsBytes</samp>

Write to a file using raw bytes `Uint8List`.

Given the document uri, opens the file in the specified `mode` and writes the `bytes` to it.

`mode` represents the mode in which the file will be opened for writing. Use `FileMode.write` for truncating (overwrite) and `FileMode.append` for appending to the file.

```dart
final Uri documentUri = ...
final String fileContent = 'My File Content';

/// Write to a file using a [Uint8List] as file contents [bytes]
final bool? success = writeToFileAsBytes(
  documentUri,
  bytes: Uint8List.fromList(utf8.encode(fileContent)),
  mode: FileMode.write,
);

/// Append to a file using a [Uint8List] as file contents [bytes]
final bool? success = writeToFileAsBytes(
  documentUri,
  bytes: Uint8List.fromList(utf8.encode(fileContent)),
  mode: FileMode.write,
);
```

### <samp>canRead</samp>

<samp>Mirror of [`DocumentFile.canRead`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#canRead()>)</samp>

Returns `true` if the caller can read the given `uri`, that is, if has the properly permissions.

```dart
final Uri uri = ...

if (await canRead(uri) ?? false) {
  print('I have permissions to read $uri');

  final Uint8List? fileContent = await getDocumentContent(uri);

  /// ...
} else {
  final UriPermission? permission = openDocumentTree(uri);

  /// ...
}
```

### <samp>canWrite</samp>

<samp>Mirror of [`DocumentFile.canWrite`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#canWrite()>)</samp>

Returns `true` if the caller can write the given `uri`, that is, if has the properly permissions.

```dart
final Uri uri = ...

if (await canWrite(uri) ?? false) {
  print('I have permissions to write $uri');

  final Uint8List? fileContent = await renameTo(uri, 'New File Name');

  /// ...
} else {
  final UriPermission? permission = openDocumentTree(
    uri,
    grantWritePermission: true,
  );

  /// ...
}
```

### <samp>getDocumentThumbnail</samp>

<samp>Mirror of [`DocumentsContract.getDocumentThumbnail`](<https://developer.android.com/reference/android/provider/DocumentsContract#getDocumentThumbnail(android.content.ContentResolver,%20android.net.Uri,%20android.graphics.Point,%20android.os.CancellationSignal)>)</samp>

Returns the image thumbnail of a given `uri`, if any (e.g documents that can show a preview, like _images_ of _gifs_, `null` otherwise).

```dart
final Uint8List? imageBytes;
final DocumentFile file = ...

final Uri? rootUri = file.metadata?.rootUri;
final String? documentId = file.data?[DocumentFileColumn.id] as String?;

if (rootUri == null || documentId == null) return;

final DocumentBitmap? bitmap = await getDocumentThumbnail(
  rootUri: rootUri,
  documentId: documentId,
  width: _size.width,
  height: _size.height,
);

if (bitmap == null || !mounted) return;

setState(() => imageBytes = bitmap.bytes);

/// Later on...
@override
Widget build(BuildContext context) {
  if (imageBytes == null) return Loading('My cool loading spinner');

  return Image.memory(imageBytes);
}
```

### <samp>DocumentFileColumn</samp>

<samp>Mirror of [`DocumentsContract.Document.<Column>`](https://developer.android.com/reference/android/provider/DocumentsContract.Document)</samp>

Use this class to refer to the SAF queryable columns in methods that requires granular/partial data fetch.

For instance, in `listFiles` a large set can be returned, and to improve performance you can provide only the columns you want access/read.

```dart
/// Columns/Fields you want access. Android handle storage as database.
/// Allow you specify only the fields you need to use, avoiding querying unnecessary data
const List<DocumentFileColumn> columns = <DocumentFileColumn>[
  DocumentFileColumn.displayName,
  DocumentFileColumn.size,
  DocumentFileColumn.lastModified,
  DocumentFileColumn.id,
  DocumentFileColumn.mimeType,
];

final Stream<DocumentFile> onNewFileLoaded = documentFileOfMyGrantedUri.listFiles(columns);
```

### <samp>delete</samp>

<samp>Mirror of [`DocumentFile.delete`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#delete()>)</samp>

Self explanatory, but just in case: delete the target uri (document file).

```dart
final Uri uri = ...

await delete(uri);
```

### <samp>createDirectory</samp>

<samp>Mirror of [`DocumentFile.createDirectory`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#createDirectory(java.lang.String)>)</samp>

Self explanatory, but just in case: creates a new child document file that represents a directory given the `displayName` (folder name).

```dart
final Uri parentUri = ...

await createDirectory(parentUri, 'My Folder Name');
```

### <samp>documentLength</samp>

<samp>Mirror of [`DocumentFile.length`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#length()>)</samp>

Returns the length of this file in bytes. Returns 0 if the file does not exist, or if the length is unknown.

```dart
final Uri uri = ...

final int? fileSize = await documentLength(uri);
```

### <samp>lastModified</samp>

<samp>Mirror of [`DocumentFile.lastModified`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#lastModified()>)</samp>

Returns the time `DateTime` when this file was last modified. Returns `null` if the file does not exist, or if the modified time is unknown.

```dart
final Uri uri = ...

final int? fileSize = await documentLength(uri);
```

### <samp>findFile</samp>

<samp>Mirror of [`DocumentFile.findFile`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#findFile(java.lang.String)>)</samp>

Search through `listFiles()` for the first document matching the given display name, this method has a really poor performance for large data sets.

```dart
final Uri directoryUri = ...

final DocumentFile? match = await findFile(directoryUri, 'Target File Name');
```

### <samp>fromTreeUri</samp>

<samp>Mirror of [`DocumentFile.fromTreeUri`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#fromTreeUri(android.content.Context,%20android.net.Uri)>)</samp>

Create a [`DocumentFile`](https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile) representing the document tree rooted at the given [`Uri`](https://developer.android.com/reference/android/net/Uri.html).

```dart
final Uri uri = ...

final DocumentFile? treeUri = fromTreeUri(uri);
```

### <samp>renameTo</samp>

<samp>Mirror of [`DocumentFile.renameTo`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#renameTo(java.lang.String)>)</samp>

Self explanatory, but just in case: rename the given document file given its uri and a new display name.

```dart
final Uri uri = ...

await renameTo(uri, 'New Document Name');
```

### <samp>parentFile</samp>

<samp>Mirror of [`DocumentFile.parentFile`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#getParentFile()>)</samp>

Returns the parent document file of a given document file (uri).

`null` if you do not have permission to see the parent folder.

```dart
final Uri uri = ...

final DocumentFile? parentUri = await parentFile(uri);
```

### <samp>copy</samp>

<samp>Mirror of [`DocumentsContract.copyDocument`](<https://developer.android.com/reference/android/provider/DocumentsContract#copyDocument(android.content.ContentResolver,%20android.net.Uri,%20android.net.Uri)>)</samp>

Copy the given `uri` to a new `destinationUri`.

```dart
final Uri uri = ...
final Uri destination = ...

final DocumentFile? copiedFile = await copy(uri, destination);
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

### <samp>getDocumentContentAsString</samp>

<samp>Alias for `getDocumentContent`</samp>

Read a document file from its uri by opening a input stream, reading its bytes and converting to `String`.

```dart
final Uri uri = ...

final String? fileContent = await getDocumentContentAsString(uri);

print(fileContent);
```

### <samp>createFileAsString</samp>

<samp>Alias for `createFileAsBytes`</samp>

Convenient method to create a file using `content` as `String` instead `Uint8List`.

```dart
final Uri parentUri = ...
final String fileContent = 'My File Content';

final DocumentFile? createdFile = createFileAsString(
  parentUri,
  mimeType: 'text/plain',
  displayName: 'Sample File Name',
  content: fileContent,
);
```

### <samp>writeToFileAsString</samp>

<samp>Alias for `writeToFileAsBytes`</samp>

Convenient method to write to a file using `content` as `String` instead `Uint8List`.

```dart
final Uri documentUri = ...
final String fileContent = 'My File Content';

/// Write to a file using a [Uint8List] as file contents [bytes]
final bool? success = writeToFileAsString(
  documentUri,
  content: fileContent,
  mode: FileMode.write,
);

/// Append to a file using a [Uint8List] as file contents [bytes]
final bool? success = writeToFileAsBytes(
  documentUri,
  content: fileContent,
  mode: FileMode.write,
);
```

### <samp>createFile</samp>

<samp>Alias for `createFileAsBytes` and `createFileAsString`</samp>

Convenient method to create a file using `content` as `String` **or** `bytes` as `Uint8List`.

You should provide either `content` or `bytes`, if both `bytes` will be used.

```dart
final Uri parentUri = ...
final String fileContent = 'My File Content';

/// Create a file using a [String] as file contents [content]
final DocumentFile? createdFile = createFile(
  parentUri,
  mimeType: 'text/plain',
  displayName: 'Sample File Name',
  content: fileContent,
);

/// Create a file using a [Uint8List] as file contents [bytes]
final DocumentFile? createdFile = createFile(
  parentUri,
  mimeType: 'text/plain',
  displayName: 'Sample File Name',
  content: Uint8List.fromList(utf8.encode(fileContent)),
);
```

### <samp>writeToFile</samp>

<samp>Alias for `writeToFileAsBytes` and `writeToFileAsString`</samp>

Convenient method to write to a file using `content` as `String` **or** `bytes` as `Uint8List`.

You should provide either `content` or `bytes`, if both `bytes` will be used.

`mode` represents the mode in which the file will be opened for writing. Use `FileMode.write` for truncating and `FileMode.append` for appending to the file.

```dart
final Uri documentUri = ...
final String fileContent = 'My File Content';

/// Write to a file using a [String] as file contents [content]
final bool? success = writeToFile(
  documentUri,
  content: fileContent,
  mode: FileMode.write,
);

/// Append to a file using a [String] as file contents [content]
final bool? success = writeToFile(
  documentUri,
  content: fileContent,
  mode: FileMode.append,
);

/// Write to a file using a [Uint8List] as file contents [bytes]
final bool? success = writeToFile(
  documentUri,
  content: Uint8List.fromList(utf8.encode(fileContent)),
  mode: FileMode.write,
);

/// Append to a file using a [Uint8List] as file contents [bytes]
final bool? success = writeToFile(
  documentUri,
  content: Uint8List.fromList(utf8.encode(fileContent)),
  mode: FileMode.append,
);
```

## External APIs (deprecated)

These APIs are from external Android libraries.

Will be moved to another package soon.

### <samp>child</samp>

<samp>Mirror of [`com.anggrayudi.storage.file.DocumentFile.child`](https://github.com/anggrayudi/SimpleStorage/blob/551fae55641dc58a9d3d99cb58fdf51c3d312b2d/storage/src/main/java/com/anggrayudi/storage/file/DocumentFileExt.kt#L270)</samp>

Get the direct child of the given uri. Can be used to verify if a file already exists and check for conflicts.

```dart
final Uri parentUri = ...

final DocumentFile? childDocument = child(parentUri, 'Sample File Name');

if (childDocument != null) {
  /// This child exists...
} else {
  /// Doesn't exists...
}
```

## Internal Types (Classes)

Internal type (class). Usually they are only to keep a safe typing and are not usually intended to be instantiated for the package user.

### <samp>DocumentFile</samp>

This class represents but is not the mirror of the original [`DocumentFile`](https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile).

This class is not intended to be instantiated, and it is only used for typing and convenient purposes.

### <samp>QueryMetadata</samp>

This class wraps useful metadata of the source queries returned by the `DocumentFile`.

This class is not intended to be instantiated, and it is only used for typing and convenience purposes.

### <samp>DocumentBitmap</samp>

This class represent the bitmap/image of a document.

Usually the thumbnail of the document.

Should be used to show a list/grid preview of a file list.

See also `getDocumentThumbnail`.

This class is not intended to be instantiated, and it is only used for typing and convenient purposes.

## Extensions

These are most alias methods implemented through Dart extensions.

### <samp>Uri.toDocumentFile on [`Uri`](https://api.dart.dev/stable/2.17.1/dart-core/Uri-class.html)</samp>

<samp>Alias for `DocumentFile.fromTreeUri(this)`</samp>

This method convert `this` uri to the respective `DocumentFile` (if exists, otherwise `null`).

```dart
final Uri uri = ...

final DocumentFile? documentFile = uri.toDocumentFile();
```

### <samp>Uri.openDocumentFile on [`Uri`](https://api.dart.dev/stable/2.17.1/dart-core/Uri-class.html)</samp>

<samp>Alias for `openDocumentFile(this)`</samp>

This method open the current uri in a third-part application through `ACTION_VIEW` intent.

```dart
final Uri uri = ...

await uri.openDocumentFile();
```

## Android Official Documentation

The **Storage Access Framework** [official documentation is available here.](https://developer.android.com/guide/topics/providers/document-provider)

All the APIs listed in this plugin module are derivated from the official docs.
