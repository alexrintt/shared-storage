## Shared Storage Flutter Plugin

[![pub package](https://img.shields.io/pub/v/shared_storage.svg)](https://pub.dartlang.org/packages/shared_storage)

Plugin to fetch Android shared storage/folders info

### Notes

- _**Android Only**_
- _**Alpha version**_
- _**Supports Android 4.1+ (API Level 16+)**_

### Features

- Get top-level external/shared folders path from [`Environment` Android API](https://developer.android.com/reference/android/os/Environment)

This plugin allow us to get path of top-level shared folder (Downloads, DCIM, Videos, Audio) using the following Android API's

```dart
/// Get Android [downloads] top-level shared folder
/// You can also create a reference to a custom directory as: `EnvironmentDirectory.custom('Custom Folder')`
final sharedDirectory = 
    await getExternalStoragePublicDirectory(EnvironmentDirectory.downloads); 

print(sharedDirectory.path); /// `/storage/emulated/0/Download`
```

- Get external/shared folders path from [`MediaStore` Android API](https://developer.android.com/training/data-storage/shared/media)

```dart
/// Get Android [downloads] shared folder for Android 9+
final sharedDirectory = 
    await getMediaStoreContentDirectory(MediaStoreCollection.downloads);

print(sharedDirectory.path); /// `/external/downloads`
```

- Get root Android path, note that is a read-only folder

```dart
/// Get Android root folder
final sharedDirectory = await getRootDirectory();

print(sharedDirectory.path); /// `/system`
```

### Android API's

Most Flutter plugins uses Android API's under the hood. So this plugin do the same, and to retrieve Android shared folder paths the following API's are being used:

[`🔗 android.os.Environment`](https://developer.android.com/reference/android/os/Environment#summary) [`🔗 android.provider.MediaStore`](https://developer.android.com/reference/android/provider/MediaStore#summary)

<br>

<h2 align="center">
  Open Source
</h2>
<p align="center">
  <sub>Copyright © 2021-present, Laks Castro.</sub>
</p>
<p align="center">Shared Storage <a href="https://github.com/LaksCastro/shared-storage/blob/master/LICENSE.md">is MIT licensed 💖</a></p>
<p align="center">
  <img src="https://user-images.githubusercontent.com/51419598/141711483-9b0f9f2b-a46d-4de1-a15f-c6c99b552ef4.png" width="35" />
</p>
