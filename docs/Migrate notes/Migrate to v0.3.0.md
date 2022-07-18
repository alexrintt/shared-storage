There's some breaking changes from `v0.2.x` then be careful when updating on `pubspec.yaml`

`pubspec.yaml` dependecy manager file:

```yaml
dependencies:
  shared_storage: v0.3.0
```

## SDK constraint

In `android\app\build.gradle` set `android.defaultConfig.minSdkVersion` to `19`:

```gradle
android {
  ...
  defaultConfig {
    ...
    minSdkVersion 19
  }
  ...
}
```

## Plugin import

Although this import is still supported:

```dart
import 'package:shared_storage/shared_storage.dart' as shared_storage;
```

This should be renamed to any of them or all:

```dart
import 'package:shared_storage/saf.dart' as saf;
import 'package:shared_storage/media_store.dart' as media_store;
import 'package:shared_storage/environment.dart' as environment;
```

Choose which modules/imports one you want to include inside in your project.

## Media Store `getMediaStoreContentDirectory`

The method `getMediaStoreContentDirectory` now returns the right class `Uri` instead of a `Directory`.

Be sure to update all ocurrences.

This `Uri` is used to represent a directory.
