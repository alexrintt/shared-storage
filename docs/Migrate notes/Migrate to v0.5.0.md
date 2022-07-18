There's major breaking changes when updating to `v0.5.0`, be careful.

Update your `pubspec.yaml`:

```yaml
dependencies:
  shared_storage: ^0.5.0
```

## Return type of `listFiles`

Instead of:

```dart
Stream<PartialDocumentFile> fileStream = listFiles(uri);
```

use:

```dart
Stream<DocumentFile> fileStream = listFiles(uri);
```

And when reading data from each file:

```dart
// Old.
PartialDocumentFile file = ...

String displayName = file.data![DocumentFileColumn.displayName] as String;
DateTime lastModified = DateTime.fromMillisecondsSinceEpoch(file.data![DocumentFileColumn.lastModified] as int);

// New.
DocumentFile file = ...

String displayName = file.name;
DateTime lastModified = file.lastModified;
```

It now parses all fields as class fields instead `Map<DocumentFileColumn, dynamic>` hash map.
