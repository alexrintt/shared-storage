## 0.7.0

- New APIs and options.
- There's no major breaking changes when updating to `v0.7.0` but there are deprecation notices over Media Store and Environment API.

### New

- `openDocument` API with single and multiple files support @honjow.
- `openDocumentTree` it now also supports `persistablePermission` option which flags an one-time operation to avoid unused permission issues.

### Deprecation notices

- All non SAF APIs are deprecated (Media Store and Environment APIs), if you are using them, let us know by [opening an issue](https://github.com/alexrintt/shared-storage/issues/new) with your use-case so we can implement a new compatible API using a cross-platform approach.

### Example project

- Added a new button that implements `openDocument` API.

## 0.6.0

This release contains a severe API fixes and some minor doc changes:

### Breaking changes

- Unused arguments in `DocumentFile.getContent` and `DocumentFile.getContentAsString`. [#107](https://github.com/alexrintt/shared-storage/issues/107) @clragon.
- Package import it's now done through a single import.

## 0.5.0

This release contains:

- Major breaking changes.
- New API to edit existing files.
- Example project improvements.
- Bug fixes.

To see details, refer to rollup PR [#100](https://github.com/alexrintt/shared-storage/pull/100).

### New

- Added `writeToFile`, `writeToFileAsString` and `writeToFileAsBytes` APIs to allow overwrite existing files by appending (`FileMode.append`) or truncating `FileMode.write` (@jfaltis).

### Breaking changes

- `listFiles` it's now returns a `Stream<DocumentFile>` instead of `Stream<PartialDocumentFile>`.
- `DocumentFile.lastModified` it's now returns a `DateTime?` instead of `Future<DateTime?>` (removed the asynchronous plugin call).
- All `DocumentFile` class fields are now nullable except by `DocumentFile.uri`.
- `createFile` doesn't requires `content` or `bytes` anymore, it's now possible to just create the file reference without defining the file data, it'll be a empty `String` by default.

### Bug fixes

- `DocumentFile.canRead` it's now calling the right API (`canRead`) instead of the similar one (`canWrite`).
- [Fix](https://github.com/alexrintt/shared-storage/pull/100/files#diff-6f516633fcc1095b16ad5e0cc2a2c9711ee903cb115835d703f3c0ccfd6e0d31R38-R62) infinite loading of `getDocumentThumbnail` API when thumbnail is not available.

### Example project

- The example project is no longer dependant of `permission_handler` plugin to request `storage` permission since it's already fully integrated with Storage Access Framework.
- File cards have now a expanded and collapsed state instead of showing all data at once.
- Icon thumbnails were added to `.apk` `image/*`, `video/*`, `text/plain` and `directories` to make easier to see what is the type of the file while navigating between the folders.
- 4 new buttons were added related to `writeToFile` API: _Write to file_ (Overwrite file contents with a predefined string), _Append to file_ (Append a predefined string to the end of the file), _Ease file content_ (Self explanatory: erase it's data but do not delete the file) and _Edit file content_ (Prompt the user with a text field to define the new file content), all buttons requires confirmation since **it can cause data loss**.
- It's now possible to create a file with a custom name through the UI (_Create a custom document_ action button on top center of the file list page).
- File card now shows the decoded uris to fix the visual pollution.

## 0.4.2

Minimal hotfix:

- Closes the `OutputStream` when creating a file [#61](https://github.com/alexrintt/shared-storage/issues/61), [#86](https://github.com/alexrintt/shared-storage/pull/86) (@jfaltis).

## 0.4.1

Minimal hotfix of the example project:

- Fix build error of the example project. Reported at [#70](https://github.com/alexrintt/shared-storage/issues/70) and fixed by [#72](https://github.com/alexrintt/shared-storage/pull/72) (@jfaltis).

## 0.4.0

Fix the current behavior of `listFiles` and `openDocumentFile` API.

### Improvements

- It's now possible to list contents of all subfolders of a granted Uri opened from `openDocumentTree` (@EternityForest).
- Now `ACTION_VIEW` intent builder through `openDocumentFile` API was fixed. So it's now possible to open any file of any kind in third party apps without needing specify the mime type.

### Breaking changes

- Removed Android specific APIs:
  - `DocumentFile.listFiles` (Now it's only available globally).
  - `buildDocumentUriUsingTree` removed due high coupling with Android API (Android specific API that are not useful on any other platforms).
  - `buildDocumentUri` removed due high coupling with Android API (Android specific API that are not useful on any other platforms).
  - `buildTreeDocumentUri` removed due high coupling with Android API (Android specific API that are not useful on any other platforms).
- `getDocumentThumbnail` now receives only the `uri` param instead of a `rootUri` and a `documentId`.
- `rootUri` field from `QueryMetadata` was removed due API ambiguity: there's no such concept in the Android API and this is not required by it to work well.

## 0.3.1

Minor improvements and bug fixes:

- Crash when ommiting `DocumentFileColumn.id` column on `listFiles` API. Thanks to @EternityForest.
- Updated docs to info that now `DocumentFileColumn.id` column is optional when calling `listFiles`.

## 0.3.0

Major release focused on support for `Storage Access Framework`.

### Breaking changes

- `minSdkVersion` set to `19`.
- `getMediaStoreContentDirectory` return type changed to `Uri`.
- Import package directive path is now modular. Which means you need to import the modules you are using:
  - `import 'package:shared_storage/saf.dart' as saf;` to enable **Storage Access Framework** API.
  - `import 'package:shared_storage/environment.dart' as environment;` to enable **Environment** API.
  - `import 'package:shared_storage/media_store.dart' as mediastore;` to enable **Media Store** API.
  - `import 'package:shared_storage/shared_storage' as sharedstorage;` if you want to import all above and as a single module (Not recommended because can conflict/override names/methods).

### New

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

- <samp>Mirror</samp> `buildTreeDocumentUri` from [`DocumentsContract.buildTreeDocumentUri`](<https://developer.android.com/reference/android/provider/DocumentsContract#buildTreeDocumentUri(java.lang.String,%20java.lang.String)>).

- <samp>Mirror</samp> `delete` from [`DocumentFile.delete`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#delete()>). Self explanatory.

- <samp>Mirror</samp> `createDirectory` from [`DocumentFile.createDirectory`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#createDirectory(java.lang.String)>). Creates a new child document file that represents a directory given the `displayName` (folder name).

- <samp>Alias</samp> `createFile`. Alias for `createFileAsBytes` or `createFileAsString` depending which params are provided.

- <samp>Mirror</samp> `createFileAsBytes` from [`DocumentFile.createFile`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#createFile(java.lang.String,%20java.lang.String)>). Given the parent uri, creates a new child document file that represents a single file given the `displayName`, `mimeType` and its `content` in bytes (file name, file type and file content in raw bytes, respectively).

- <samp>Alias</samp> `createFileAsString`. Alias for `createFileAsBytes(bytes: Uint8List.fromList('file content...'.codeUnits))`.

- <samp>Mirror</samp> `documentLength` from [`DocumentFile.length`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#length()>). Returns the length of the given file (uri) in bytes. Returns 0 if the file does not exist, or if the length is unknown.

- <samp>Mirror</samp> `lastModified` from [`DocumentFile.lastModified`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#lastModified()>). Returns the time when the given file (uri) was last modified, measured in milliseconds since January 1st, 1970, midnight. Returns 0 if the file does not exist, or if the modified time is unknown.

- <samp>Mirror</samp> `findFile` from [`DocumentFile.findFile`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#findFile(java.lang.String)>). Search through listFiles() for the first document matching the given display name, this method has a really poor performance for large data sets, prefer using `child` instead.

- <samp>Mirror</samp> `fromTreeUri` from [`DocumentFile.fromTreeUri`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#fromTreeUri(android.content.Context,%20android.net.Uri)>).

- <samp>Mirror</samp> `renameTo` from [`DocumentFile.renameTo`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#renameTo(java.lang.String)>). Rename a document file given its `uri` to the given `displayName`.

- <samp>Mirror</samp> `parentFile` from [`DocumentFile.parentFile`](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#getParentFile()>). Get the parent document of the given document file from its uri.

- <samp>Mirror</samp> `copy` from [`DocumentsContract.copyDocument`](<https://developer.android.com/reference/android/provider/DocumentsContract#copyDocument(android.content.ContentResolver,%20android.net.Uri,%20android.net.Uri)>). Copies the given document to the given `destination`.

- <samp>Original</samp> `getDocumentContent`. Read a document file from its uri by opening a input stream and returning its bytes.

- <samp>External</samp> `child` from [`com.anggrayudi.storage.file.DocumentFile.child`](https://github.com/anggrayudi/SimpleStorage/blob/551fae55641dc58a9d3d99cb58fdf51c3d312b2d/storage/src/main/java/com/anggrayudi/storage/file/DocumentFileExt.kt#L270). Find the child file of a given parent uri and child name, null if doesn't exists (faster than `findFile`).

- <samp>Original `UNSTABLE`</samp> `openDocumentFile`. Open a file uri in a external app, by starting a new activity with `ACTION_VIEW` Intent.

- <samp>Original `UNSTABLE`</samp> `getRealPathFromUri`. Return the real path to work with native old `File` API instead Uris, be aware this approach is no longer supported on Android 10+ (API 29+) and though new, this API is **marked as deprecated** and should be migrated to a _scoped-storage_ approach.

- <samp>Alias</samp> `getDocumentContentAsString`. Alias for `getDocumentContent`. Convert all bytes returned by the original method into a `String`.

- <samp>Internal</samp> `DocumentBitmap` class added. Commonly used as thumbnail image/bitmap of a `DocumentFile`.

- <samp>Extension</samp> `UriDocumentFileUtils` on `Uri` (Accesible by `uri.extensionMethod(...)`).

  - <samp>Alias</samp> `toDocumentFile`. Alias for `DocumentFile.fromTreeUri(this)` which is an alias for `fromTreeUri`. method: convert `this` to the respective `DocumentFile` (if exists, otherwise `null`).
  - <samp>Alias</samp> `openDocumentFile`. Alias for `openDocumentFile`.

- <samp>Mirror</samp> `getDownloadCacheDirectory` from [`Environment.getDataDirectory`](https://developer.android.com/reference/android/os/Environment#getDownloadCacheDirectory%28%29).

- <samp>Mirror</samp> `getStorageDirectory` from [`Environment.getStorageDirectory`](https://developer.android.com/reference/android/os/Environment#getStorageDirectory%28%29).

### Deprecation notices

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
