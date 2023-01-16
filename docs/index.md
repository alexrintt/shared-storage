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

## Plugin

This plugin include **partial** support for the following APIs:

### Partial Support for [Environment](./Usage/Environment.md)

Mirror API from [Environment](https://developer.android.com/reference/android/os/Environment)

```dart
import 'package:shared_storage/environment.dart' as environment;
```

### Partial Support for [Media Store](./Usage/Media%20Store.md)

Mirror API from [MediaStore provider](https://developer.android.com/reference/android/provider/MediaStore)

```dart
import 'package:shared_storage/media_store.dart' as mediastore;
```

### Partial Support for [Storage Access Framework](./Usage/Storage%20Access%20Framework.md)

Mirror API from [Storage Access Framework](https://developer.android.com/guide/topics/providers/document-provider)

```dart
import 'package:shared_storage/saf.dart' as saf;
```

All these APIs are module based, which means they are implemented separadely and so you need to import those you want use.

> To request support for some API that is not currently included open a issue explaining your usecase and the API you want to make available, the same applies for new methods or activities for the current APIs.

## Contribute

If you have ideas to share, bugs to report or need support, you can open an issue.

## Android APIs

Most Flutter plugins use Android API's under the hood. So this plugin does the same, and to call native Android storage APIs the following API's are being used:

[`🔗android.os.Environment`](https://developer.android.com/reference/android/os/Environment#summary) [`🔗android.provider.MediaStore`](https://developer.android.com/reference/android/provider/MediaStore#summary) [`🔗android.provider.DocumentsProvider`](https://developer.android.com/guide/topics/providers/document-provider)

## Supporters

- [aplicatii-romanesti](https://www.bibliotecaortodoxa.ro/) who bought me a whole month of caffeine!

## Contributors

- [honjow](https://github.com/honjow) contributed by [implementing `openDocument` Android API #110](https://github.com/alexrintt/shared-storage/pull/110) to pick single or multiple file URIs. Really helpful, thanks!
- [clragon](https://github.com/clragon) submitted a severe [bug report #107](https://github.com/alexrintt/shared-storage/issues/107) and opened [discussions around package architecture #108](https://github.com/alexrintt/shared-storage/discussions/108), thanks!
- [jfaltis](https://github.com/jfaltis) fixed [a memory leak #86](https://github.com/alexrintt/shared-storage/pull/86) and implemented an API to [override existing files #85](https://github.com/alexrintt/shared-storage/pull/85), thanks for your contribution!
- [EternityForest](https://github.com/EternityForest) did [report a severe crash #50](https://github.com/alexrintt/shared-storage/issues/50) when the column ID was not provided and [implemented a new feature to list all subfolders #59](https://github.com/alexrintt/shared-storage/pull/59), thanks man!
- Thanks [dhaval-k-simformsolutions](https://github.com/dhaval-k-simformsolutions) for taking time to submit [bug reports](https://github.com/alexrintt/shared-storage/issues?q=is%3Aissue+author%3Adhaval-k-simformsolutions) related to duplicated file entries!
- [dangilbert](https://github.com/dangilbert) pointed and [fixed a bug #14](https://github.com/alexrintt/shared-storage/pull/14) when the user doesn't select a folder, thanks man!
- A huge thanks to [aplicatii-romanesti](https://www.bibliotecaortodoxa.ro/) for taking time to submit [device specific issues](https://github.com/alexrintt/shared-storage/issues?q=author%3Aaplicatii-romanesti)!
- I would thanks [ankitparmar007](https://github.com/ankitparmar007) for [discussing and requesting create file related APIs #20](https://github.com/alexrintt/shared-storage/issues/10)!

