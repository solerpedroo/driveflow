/// Extensões utilitárias para [Iterable].
extension IterableExtensions<E> on Iterable<E> {
  /// Primeiro elemento ou `null` se vazio.
  E? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
