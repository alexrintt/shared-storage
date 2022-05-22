## 0.3.0

Major release focused on support for `Storage Access Framework`.

- New `minSdkVersion` set to `19`.
- `getMediaStoreContentDirectory` return type set to `Uri`.
- `getExternalStoragePublicDirectory` was marked as deprecated and should be replaced with an equivalent API depending on your use-case, see [how to migrate `getExternalStoragePublicDirectory`](https://stackoverflow.com/questions/56468539/getexternalstoragepublicdirectory-deprecated-in-android-q).

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
