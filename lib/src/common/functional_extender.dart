extension FunctionalExtender<T> on T? {
  /// ```dart
  /// final String? myNullableVar = ...
  ///
  /// // Really annoying repetitive condition
  /// if (myNullableVar != null) return null;
  ///
  /// return doSomethingElseWith(myNullableVar);
  /// ```
  ///
  /// This extension allow an alternative usage:
  /// ```
  /// final String? myNullableVar = ...
  ///
  /// return myNullableVar?.apply((m) => doSomethingElseWith(m));
  /// ```
  R? apply<R>(R Function(T) f) {
    // Local variable to allow automatic type promotion.  Also see:
    // <https://github.com/dart-lang/language/issues/1397>
    final T? self = this;

    return self == null ? null : f(self);
  }

  T? takeIf(bool Function(T) f) {
    final T? self = this;

    return self != null && f(self) ? self : null;
  }
}
