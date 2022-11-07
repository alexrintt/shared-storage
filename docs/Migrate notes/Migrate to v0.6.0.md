There's major breaking changes when updating to `v0.6.0`, be careful.

Update your `pubspec.yaml`:

```yaml
dependencies:
  shared_storage: ^0.6.0
```

## Import statement

Instead of:

```dart
import 'package:shared_storage/environment.dart' as environment;
import 'package:shared_storage/media_store.dart' as environment;
import 'package:shared_storage/saf.dart' as environment;
```

Import as:

```dart
import 'package:shared_storage/shared_storage' as shared_storage;
```

It's now has all APIs available under `shared_storage` key.

## `getContent()` and `getContentAsString()`

Wrongly the previous versions required an unused parameter called `destination`:

```dart
uri.getContentAsString(uri);
uri.getContent(uri);
```

It now has been removed:

```dart
uri.getContentAsString();
uri.getContent();
```
