<p align="center">
  <img src="https://user-images.githubusercontent.com/51419598/161439601-fc228a0d-d09d-4dbb-b5a3-ebc5dbcf9f46.png">
</p>

<h6 align="center"><samp>#flutter, #package, #android, #saf, #storage</samp></h6>
<samp><h1 align="center">Shared Storage</h1></samp>

<h6 align="center">
    <samp>
      Access Android <kbd>Storage Access Framework</kbd>, <kbd>Media Store</kbd> and <kbd>Environment</kbd> APIs through your Flutter Apps
    </samp>
</h6>

<p align="center">
  <a href="https://pub.dev/packages/shared_storage"><img src="https://img.shields.io/pub/v/shared_storage.svg?style=for-the-badge&color=22272E&showLabel=false&labelColor=15191f&logo=dart&logoColor=blue"></a>
  <img src="https://img.shields.io/badge/Kotlin-22272E?&style=for-the-badge&logo=kotlin&logoColor=9966FF">
  <img src="https://img.shields.io/badge/Dart-22272E?style=for-the-badge&logo=dart&logoColor=2BB7F6">
  <img src="https://img.shields.io/badge/Flutter-22272E?style=for-the-badge&logo=flutter&logoColor=66B1F1">
</p>

<a href="https://pub.dev/packages/shared_storage"><h4 align="center"><samp>Install It</samp></h4></a>

<br>

## Support

If you have ideas to share, bugs to report or need support, you can either open an issue or join our Discord server

<a href="https://discord.gg/86GDERXZNS">
  <kbd><img src="https://discordapp.com/api/guilds/771498135188799500/widget.png?style=banner2" alt="Discord Banner"/></kbd>
</a>

## Plugin

Useful plugin to call native Android APIs from Storage Access Framework, Media Store and Environment

Supported use-cases:

```py
# todo(@lakscastro): under-development
```

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

## Contributors

These are the brilliant minds behind the development of this plugin!

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://lakscastro.github.io"><img src="https://avatars.githubusercontent.com/u/51419598?v=4?s=100" width="100px;" alt=""/><br /><sub><b>lask</b></sub></a><br /><a href="https://github.com/lakscastro/shared-storage/commits?author=lakscastro" title="Code">💻</a> <a href="#maintenance-lakscastro" title="Maintenance">🚧</a> <a href="https://github.com/lakscastro/shared-storage/commits?author=lakscastro" title="Documentation">📖</a></td>
    <td align="center"><a href="https://github.com/ankitparmar007"><img src="https://avatars.githubusercontent.com/u/73648141?v=4?s=100" width="100px;" alt=""/><br /><sub><b>ankitparmar007</b></sub></a><br /><a href="https://github.com/lakscastro/shared-storage/issues?q=author%3Aankitparmar007" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://www.bibliotecaortodoxa.ro"><img src="https://avatars.githubusercontent.com/u/1148228?v=4?s=100" width="100px;" alt=""/><br /><sub><b>www.bibliotecaortodoxa.ro</b></sub></a><br /><a href="https://github.com/lakscastro/shared-storage/commits?author=aplicatii-romanesti" title="Code">💻</a> <a href="https://github.com/lakscastro/shared-storage/issues?q=author%3Aaplicatii-romanesti" title="Bug reports">🐛</a> <a href="#ideas-aplicatii-romanesti" title="Ideas, Planning, & Feedback">🤔</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

<br>

<samp>

<h2 align="center">
  Open Source
</h2>
<p align="center">
  <sub>Copyright © 2021-present, Laks Castro.</sub>
</p>
<p align="center">Shared Storage <a href="https://github.com/LaksCastro/shared-storage/blob/master/LICENSE.md">is MIT licensed 💖</a></p>
<p align="center">
  <img src="https://user-images.githubusercontent.com/51419598/161439601-fc228a0d-d09d-4dbb-b5a3-ebc5dbcf9f46.png" width="35" />
</p>
  
</samp>
