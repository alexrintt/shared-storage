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

## Instalattion

```
flutter pub add shared_storage
```

or

```yaml
dependencies:
  # ...other deps
  shared_storage: ^latest # Pickup the latest version either from the pub.dev page or the badge in this README.md
  # ...other deps
```

## Plugin

This plugin include support for the following APIs:

- [Partial Support for Environment API](https://github.com/lakscastro/shared-storage/wiki/Environment-API)

```dart
import 'package:shared_storage/environment.dart' as environment;
```

- [Partial Support for Media Store API](https://github.com/lakscastro/shared-storage/wiki/Media-Store-API)

```dart
import 'package:shared_storage/media_store.dart' as mediastore;
```

- [Partial Support for Storage Access Framework](https://github.com/lakscastro/shared-storage/wiki/Storage-Access-Framework-API)

```dart
import 'package:shared_storage/saf.dart' as saf;
```

All these APIs are module based, which means they are implemented separadely and so you need to import those you want use.

**Please, be aware:** this is plugin is not intended for production usage yet, since the API is unstable and can change anytime.

> To request support for some API that is not currently included open a issue explaining your usecase and the API you want to make available, the same applies for new methods or activities for the current APIs.

<br>

## Support

If you have ideas to share, bugs to report or need support, you can either open an issue or [join our Discord server.](https://discord.gg/86GDERXZNS)

<br />

## Android APIs

Most Flutter plugins use Android API's under the hood. So this plugin does the same, and to call native Android storage APIs the following API's are being used:

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
  <img src="https://user-images.githubusercontent.com/51419598/161439601-fc228a0d-d09d-4dbb-b5a3-ebc5dbcf9f46.png" width="35" />
</p>
