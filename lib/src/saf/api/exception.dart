/// Exception thrown when the provided URI is invalid, possible reasons:
///
/// - You have no permissions to read or write in the provided URI/File.
/// - The file was deleted and you are trying to read.
/// - [delete] and [readDocumentContent] ran at the same time.
class SharedStorageFileNotFoundException extends SharedStorageException {
  const SharedStorageFileNotFoundException(super.message, super.stackTrace);
}

/// Exception thrown in the platform-side and that cannot be addressed by the client.
///
/// You can continue the program flow ignoring this exception or open a issue if it's fatal.
class SharedStorageInternalException extends SharedStorageException {
  const SharedStorageInternalException(super.message, super.stackTrace);
}

/// Exception thrown when the user does not select a folder when calling [SharedStorage.pickScopedDirectory].
class SharedStorageDirectoryWasNotSelectedException
    extends SharedStorageException {
  const SharedStorageDirectoryWasNotSelectedException(
    super.message,
    super.stackTrace,
  );
}

/// Exception thrown when the user does not select a folder when calling [SharedStorage.pickScopedDirectory].
class SharedStorageFileWasNotSelectedException extends SharedStorageException {
  const SharedStorageFileWasNotSelectedException(
    super.message,
    super.stackTrace,
  );
}

class SharedStorageExternalAppNotFoundException extends SharedStorageException {
  const SharedStorageExternalAppNotFoundException(
    super.message,
    super.stackTrace,
  );
}

class SharedStorageSecurityException extends SharedStorageException {
  const SharedStorageSecurityException(
    super.message,
    super.stackTrace,
  );
}

class SharedStorageUnknownException extends SharedStorageException {
  const SharedStorageUnknownException(
    super.message,
    super.stackTrace,
  );
}

/// Custom type for exceptions of [shared_storage] package.
class SharedStorageException implements Exception {
  const SharedStorageException(this.message, this.stackTrace);

  final String message;
  final StackTrace stackTrace;

  @override
  String toString() => '$message $stackTrace';
}
