import 'dart:async';

abstract class ScopedFileSystemEntity {
  /// The URI representing the absolute location of this file system entity.
  Uri get uri;

  String get displayName;

  String get id;

  Uri? get parentUri;

  DateTime get lastModified;

  // FutureOr<int> length();

  // DateTime get lastModified;

  FutureOr<ScopedFileSystemEntity> copyTo(
    Uri destination, {
    bool recursive = false,
  });

  FutureOr<bool> exists();

  FutureOr<ScopedFileSystemEntity> rename(String displayName);

  FutureOr<void> delete({bool recursive = false});

  FutureOr<bool> canRead();
  FutureOr<bool> canWrite();
}

// final FileSystemEntity a;
