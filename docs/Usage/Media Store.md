## Import package

```dart
import 'package:shared_storage/media_store.dart' as mediastore;
```

> **Note** Be aware that if you import the package `import '...' as mediastore;` (strongly recommended) you should prefix all method calls with `mediastore`, example:

```dart
mediastore.getMediaStoreContentDirectory(...);
```

But if you import without alias `import '...';` (Not recommeded because can conflict with other method/package names) you should use directly as functions:

```dart
getMediaStoreContentDirectory(...);
```

## API reference

### <samp>getMediaStoreContentDirectory</samp>

Get the **directory** of a given Media Store Collection

To see all available collections see `MediaStoreCollection` class

```dart
final directory = getMediaStoreContentDirectory(MediaStoreCollection.downloads);
```
