Check out [pub.dev/shared_storage](https://pub.dev/packages/shared_storage)

## Stability

The latest version is a Beta release, which means all these APIs can change over a short period of time without prior notice.

So, please be aware that this is plugin is not intended for production usage yet, since the API is currently in development.

## Installation

![Package version badge](https://img.shields.io/pub/v/shared_storage.svg?style=for-the-badge&color=22272E&showLabel=false&labelColor=15191f&logo=dart&logoColor=blue)

Use latest version when installing this plugin:

```bash
flutter pub add shared_storage
```

or

```yaml
dependencies:
  shared_storage: ^latest # Pickup the latest version either from the pub.dev page or doc badge
```

Import:


```dart
import 'package:shared_storage/shared_storage.dart' as shared_storage;
```

## Plugin

This plugin include **partial** support for the following APIs:

### Partial Support for [Environment](./Usage/Environment.md)

Mirror API from [Environment](https://developer.android.com/reference/android/os/Environment)


### Partial Support for [Media Store](./Usage/Media%20Store.md)

Mirror API from [MediaStore provider](https://developer.android.com/reference/android/provider/MediaStore)

### Partial Support for [Storage Access Framework](./Usage/Storage%20Access%20Framework.md)

Mirror API from [Storage Access Framework](https://developer.android.com/guide/topics/providers/document-provider)


All these APIs are module based, which means they are implemented separadely and so you need to import those you want use.

> To request support for some API that is not currently included open a issue explaining your usecase and the API you want to make available, the same applies for new methods or activities for the current APIs.

## Support

If you have ideas to share, bugs to report or need support, you can either open an issue or join our [Discord server](https://discord.gg/86GDERXZNS).

## Android APIs

Most Flutter plugins use Android API's under the hood. So this plugin does the same, and to call native Android storage APIs the following API's are being used:

[`🔗android.os.Environment`](https://developer.android.com/reference/android/os/Environment#summary) [`🔗android.provider.MediaStore`](https://developer.android.com/reference/android/provider/MediaStore#summary) [`🔗android.provider.DocumentsProvider`](https://developer.android.com/guide/topics/providers/document-provider)

---

Thanks to all [contributors](https://github.com/alexrintt/shared-storage/tree/release#contributors).