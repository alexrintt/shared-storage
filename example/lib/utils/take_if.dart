extension TakeIf<T> on T {
  T? takeIf(bool Function(T) predicate) {
    final T self = this;

    return predicate(self) ? this : null;
  }
}
