/// Exception thrown when the provided URI is invalid, possible reasons:
///
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

/// Custom type for exceptions of [shared_storage] package.
class SharedStorageException implements Exception {
  const SharedStorageException(this.message, this.stackTrace);

  final String message;
  final StackTrace stackTrace;

  @override
  String toString() => '$message $stackTrace';
}
