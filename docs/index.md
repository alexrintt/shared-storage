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

## Support

If you have ideas to share, bugs to report or need support, you can either open an issue or join our [Discord server](https://discord.gg/86GDERXZNS).

## Android APIs

Most Flutter plugins use Android API's under the hood. So this plugin does the same, and to call native Android storage APIs the following API's are being used:

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
    <td align="center"><a href="https://github.com/dangilbert"><img src="https://avatars.githubusercontent.com/u/6799566?v=4?s=100" width="100px;" alt=""/><br /><sub><b>dangilbert</b></sub></a><br /><a href="https://github.com/lakscastro/shared-storage/commits?author=dangilbert" title="Code">💻</a> <a href="https://github.com/lakscastro/shared-storage/issues?q=author%3Adangilbert" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://github.com/dhaval-k-simformsolutions"><img src="https://avatars.githubusercontent.com/u/90894202?v=4?s=100" width="100px;" alt=""/><br /><sub><b>dhaval-k-simformsolutions</b></sub></a><br /><a href="https://github.com/lakscastro/shared-storage/issues?q=author%3Adhaval-k-simformsolutions" title="Bug reports">🐛</a> <a href="#ideas-dhaval-k-simformsolutions" title="Ideas, Planning, & Feedback">🤔</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->
