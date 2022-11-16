There's no major breaking changes when updating to `v0.7.0` but there are deprecation notices if you are using Media Store and Environment API.

Update your `pubspec.yaml`:

```yaml
dependencies:
  shared_storage: ^0.7.0
```

## Deprecation notices

All non SAF APIs are deprecated, if you are using them, let us know by [opening an issue](https://github.com/alexrintt/shared-storage/issues/new) with your use-case so we can implement a new compatible API using a cross-platform approach.
