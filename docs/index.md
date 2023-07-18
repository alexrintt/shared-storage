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

## Permissions (optional)

The following APIs require the `REQUEST_INSTALL_PACKAGES` permission in order to prompt the user to install arbitrary APKs:

- `openDocumentFile` when trying to open APK files.

If your want to display APK files inside your app and let users install it, then you need this permission, if that's not the case then you can just skip this step.

```xml
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
```

> Warning! In some cases the app can become ineligible in the Play Store when using this permission, be sure you need it. Most cases where you think you don't need it you are goddamn right.


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

If you have ideas to share, bugs to report or need support, you can either open an issue or join our [Discord server](https://discord.alexrintt.io).

---

Last but not least, [thanks to all contributors](https://github.com/alexrintt/shared-storage/tree/release#contributors) that makes this plugin a better tool.