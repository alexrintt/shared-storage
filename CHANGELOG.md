## 0.3.0

Major release focused on support for `Storage Access Framework`.

### Breaking Changes

- `minSdkVersion` set to `19`.
- `getMediaStoreContentDirectory` return type changed to `Uri`.
- Import package directive path is now modular. Which means you need to import the modules you are using:
  - `import 'package:shared_storage/saf.dart' as saf;` to enable **Storage Access Framework** API.
  - `import 'package:shared_storage/environment.dart' as environment;` to enable **Environment** API.
  - `import 'package:shared_storage/media_store.dart' as mediastore;` to enable **Media Store** API.
  - `import 'package:shared_storage/shared_storage' as sharedstorage;` if you want to import all above and as a single module (Not recommended because can conflict/override names/methods).

### New Features

See the label [reference here](/docs/Usage/API%20Labeling.md).

- <samp>Original</samp> `listFiles`. This API does the same thing as `DocumentFile.listFiles` but through Android queries and not calling directly the `DocumentFile.listFiles` API for performance reasons.

- <samp>Internal</samp> `DocumentFile` from [`DocumentFile`](https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile) SAF class.

- <samp>Internal</samp> `QueryMetadata` metadata of the queries used by `listFiles` API.

- <samp>Internal</samp> `PartialDocumentFile`. Represents a partial document file returned by `listFiles` API.

- `openDocumentTree` now accepts `grantWritePermission` and `initialUri` params which, respectively, sets whether or not grant write permission level and the initial uri location of the folder authorization picker.

- <samp>Mirror</samp> `DocumentFileColumn` from [`DocumentsContract.Document.<Column>`](https://developer.android.com/reference/android/provider/DocumentsContract.Document) SAF class.

- <samp>Mirror</samp> `canRead` from [`DocumentFile.canRead`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#canRead()>). Returns `true` if the caller can read the given `uri`.

- <samp>Mirror</samp> `canWrite` from [`DocumentFile.canWrite`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#canWrite()>). Returns `true` if the caller can write to the given `uri`.

- <samp>Mirror</samp> `getDocumentThumbnail` from [`DocumentsContract.getDocumentThumbnail`](<https://developer.android.com/reference/android/provider/DocumentsContract#getDocumentThumbnail(android.content.ContentResolver,%20android.net.Uri,%20android.graphics.Point,%20android.os.CancellationSignal)>). Returns the image thumbnail of a given `uri`, if any (e.g documents that can show a preview, like image or pdf, otherwise `null`).

- <samp>Mirror</samp> `exists` from [`DocumentsContract.exists`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#exists()>). Returns `true` if a given `uri` exists.

- <samp>Mirror</samp> `buildDocumentUriUsingTree` from [`DocumentsContract.buildDocumentUriUsingTree`](<https://developer.android.com/reference/android/provider/DocumentsContract#buildDocumentUriUsingTree(android.net.Uri,%20java.lang.String)>).

- <samp>Mirror</samp> `buildDocumentUri` from [`DocumentsContract.buildDocumentUri`](<https://developer.android.com/reference/android/provider/DocumentsContract#buildDocumentUri(java.lang.String,%20java.lang.String)>).

- <samp>Mirror</samp> `buildDocumentUri` from [`DocumentsContract.buildDocumentUri`](<https://developer.android.com/reference/android/provider/DocumentsContract#buildDocumentUri(java.lang.String,%20java.lang.String)>).

- <samp>Mirror</samp> `buildTreeDocumentUri` from [`DocumentsContract.buildTreeDocumentUri`](<https://developer.android.com/reference/android/provider/DocumentsContract#buildTreeDocumentUri(java.lang.String,%20java.lang.String)>).

- <samp>Mirror</samp> `createFile` from [`DocumentFile.createFile`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#createFile(java.lang.String,%20java.lang.String)>). Create a child file from given a parent uri.

- <samp>Mirror</samp> `delete` from [`DocumentFile.delete`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#delete()>). Self explanatory.

- <samp>Mirror</samp> `createDirectory` from [`DocumentFile.createDirectory`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#createDirectory(java.lang.String)>). Creates a new child document file that represents a directory given the `displayName` (folder name).

- <samp>Mirror</samp> `createFile` from [`DocumentFile.createFile`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#createFile(java.lang.String,%20java.lang.String)>). Creates a new child document file that represents a single file given the `displayName` and the `mimeType` (file name and file type, respectively).

- <samp>Alias</samp> `createFileAsBytes`. Alias for `createFile(bytes: Uint8List.fromList('file content...'.codeUnits))`.

- <samp>Alias</samp> `createFileAsString`. Alias for `createFile(content: 'file content...')`.

- <samp>Mirror</samp> `documentLength` from [`DocumentFile.length`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#length()>). Returns the length of this file in bytes. Returns 0 if the file does not exist, or if the length is unknown.

- <samp>Mirror</samp> `lastModified` from [`DocumentFile.lastModified`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#lastModified()>). Returns the time when this file was last modified, measured in milliseconds since January 1st, 1970, midnight. Returns 0 if the file does not exist, or if the modified time is unknown.

- <samp>Mirror</samp> `findFile` from [`DocumentFile.findFile`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#findFile(java.lang.String)>). Search through listFiles() for the first document matching the given display name, this method has a really poor performance for large data sets, prefer using `child` instead.

- <samp>Mirror</samp> `fromTreeUri` from [`DocumentFile.fromTreeUri`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#fromTreeUri(android.content.Context,%20android.net.Uri)>).

- <samp>Mirror</samp> `renameTo` from [`DocumentFile.renameTo`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#renameTo(java.lang.String)>). Rename a document file given its `uri` to the given `displayName`.

- <samp>Mirror</samp> `parentFile` from [`DocumentFile.parentFile`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#getParentFile()>). Get the parent document of the given document file from its uri.

- <samp>Mirror</samp> `copy` from [`DocumentsContract.copyDocument`](<https://developer.android.com/reference/android/provider/DocumentsContract#copyDocument(android.content.ContentResolver,%20android.net.Uri,%20android.net.Uri)>). Copies the given document to the given `destination`.

- <samp>Original</samp> `getDocumentContent`. Read a document file from its uri by opening a input stream and returning its bytes.

- <samp>Alias</samp> `getDocumentContentAsString`. Alias for `getDocumentContent` except this convert the bytes to `String`.

- <samp>External</samp> `child` from [`com.anggrayudi.storage.file.DocumentFile.child`](https://github.com/anggrayudi/SimpleStorage/blob/551fae55641dc58a9d3d99cb58fdf51c3d312b2d/storage/src/main/java/com/anggrayudi/storage/file/DocumentFileExt.kt#L270). Find the child file of a given parent uri and child name, null if doesn't exists (faster than `findFile`).

- <samp>Original `UNSTABLE`</samp> `openDocumentFile`. Open a file uri in a external app, by starting a new activity with `ACTION_VIEW` Intent.

- <samp>Original `UNSTABLE`</samp> `getRealPathFromUri`. Return the real path to work with native old `File` API instead Uris, be aware this approach is no longer supported on Android 10+ (API 29+) and though new, this API is **marked as deprecated** and should be migrated to a _scoped-storage_ approach.

- <samp>Alias</samp> `getDocumentContentAsString`. Alias for `getDocumentContent`. Convert all bytes returned by the original method into a `String`.

- <samp>Internal</samp> `DocumentBitmap` class added. Commonly used as thumbnail image/bitmap of a `DocumentFile`.

- <samp>Extension</samp> `UriDocumentFileUtils` on `Uri` (Accesible by `uri.extensionMethod(...)`).

  - <samp>Alias</samp> `toDocumentFile`. Alias for `DocumentFile.fromTreeUri(this)` which is an alias for `fromTreeUri`. method: convert `this` to the respective `DocumentFile` (if exists, otherwise `null`).
  - <samp>Alias</samp> `open`. Alias for `openDocumentFile`.
  - <samp>Alias</samp> `openDocumentFile`. Alias for `openDocumentFile` (same of `open` alias with a more specific name).

- <samp>Mirror</samp> `getDownloadCacheDirectory` from [`Environment.getDataDirectory`](https://developer.android.com/reference/android/os/Environment#getDownloadCacheDirectory%28%29).

- <samp>Mirror</samp> `getStorageDirectory` from [`Environment.getStorageDirectory`](https://developer.android.com/reference/android/os/Environment#getStorageDirectory%28%29).

### Deprecation Notices

- `getExternalStoragePublicDirectory` was marked as deprecated and should be replaced with an equivalent API depending on your use-case, see [how to migrate `getExternalStoragePublicDirectory`](https://stackoverflow.com/questions/56468539/getexternalstoragepublicdirectory-deprecated-in-android-q). This deprecation is originated from official Android documentation and not by the plugin itself.

## 0.2.0

Add basic support for `Storage Access Framework` and `targetSdk 31`.

- The package now supports basic intents from `Storage Access Framework`.
- Your App needs update the `build.gradle` by targeting the current sdk to `31`.

## 0.1.1

Minor improvements on `pub.dev` documentation.

- Add `example/` folder.
- Add missing `pubspec.yaml` properties.

## 0.1.0

Initial release.
