## Shared Storage Flutter Plugin

[![pub package](https://img.shields.io/pub/v/shared_storage.svg)](https://pub.dartlang.org/packages/shared_storage)

Plugin to fetch Android shared storage/folders info

### Notes

- _**Android Only**_
- _**Alpha version**_
- _**Supports Android 4.1+ (API Level 16+)**_
- _**The `targetSdk` should be set to `31`**_

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

- Start `OPEN_DOCUMENT_TREE` activity to prompt user to select an folder to enable write and read access to be used by the `Storage Access Framework` API

```dart
/// Get permissions to manage an Android directory
final selectedUriDir = await openDocumentTree();

print(selectedUriDir);
```

- Create a new file using the `SAF` API

```dart
/// Create a new file using the `SAF` API
final newDocumentFile = await createDocumentFile(
  mimeType: 'text/plain',
  content: 'My Plain Text Comment Created by shared_storage plugin',
  displayName: 'CreatedBySharedStorageFlutterPlugin',
  directory: anySelectedUriByTheOpenDocumentTreeAPI,
);

print(newDocumentFile);
```

- Get all persisted [URI]s by the `openDocumentTree` API, from `SAF` API

```dart
/// You have [write] and [read] access to all persisted [URI]s
final listOfPersistedUris = await persistedUriPermissions();

print(listOfPersistedUris);
```

- Revoke a current persisted [URI], from `SAF` API

```dart
/// Can be any [URI] returned by the `persistedUriPermissions`
final uri = ...;

/// After calling this, you no longer has access to the [uri]
await releasePersistableUriPermission(uri);
```

- Convenient method to know if a given [uri] is a persisted `uri` ("persisted uri" means that you have `write` and `read` access to the `uri` even if devices reboot)

```dart
/// Can be any [URI], but the method will only return [true] if the [uri]
/// is also present in the list returned by `persistedUriPermissions`
final uri = ...;

/// Verify if you have [write] and [read] access to a given [uri]
final isPersisted = await isPersistedUri(uri);
```

### Android API's

Most Flutter plugins uses Android API's under the hood. So this plugin do the same, and to retrieve Android shared folder paths the following API's are being used:

[`🔗android.os.Environment`](https://developer.android.com/reference/android/os/Environment#summary) [`🔗android.provider.MediaStore`](https://developer.android.com/reference/android/provider/MediaStore#summary) [`🔗android.provider.DocumentsProvider`](https://developer.android.com/guide/topics/providers/document-provider)

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
