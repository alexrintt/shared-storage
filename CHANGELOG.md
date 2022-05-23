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

- <samp>Mirror</samp> `createFile` from [DocumentFile.createFile()](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#createFile(java.lang.String,%20java.lang.String)>). Create a child file from given a parent uri.

- <samp>Mirror</samp> `child` from [DocumentFile.child()](<https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile#createFile(java.lang.String,%20java.lang.String)>). Find the child file of a given parent uri and child name, null if doesn't exists.

- <samp>Original `UNSTABLE`</samp> `openDocumentFile`. Open a file uri in a external app, by starting a new activity with `ACTION_VIEW` Intent.

- <samp>Original `UNSTABLE`</samp> `getRealPathFromUri`. Return the real path to work with native old `File` API instead Uris, be aware this approach is no longer supported on Android 10+ (API 29+) and though new, this API is **marked as deprecated** and should be migrated to a _scoped-storage_ approach.

- <samp>Alias</samp> `getDocumentContentAsString`. Alias for `getDocumentContent` and convert all bytes into `String`.

-

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
