extension IterableExtension on Iterable {
  void doInBetween<T>(Function(T, T) function) {
    Iterator iterator = this.iterator;
    iterator.moveNext();

    T current = iterator.current,
        next;

    while (iterator.moveNext()) {
      next = iterator.current;

      function(current, next);

      current = next;
    }
  }

  void zip<T, K>(Iterable<T> iterable, Function(K, T) function) {
    Iterator thisIterator = this.iterator,
        otherIterator = iterable.iterator;


    while (thisIterator.moveNext() && otherIterator.moveNext()) {
      K thisCurrent = thisIterator.current;
      T otherCurrent = otherIterator.current;

      function(thisCurrent, otherCurrent);
    }
  }
}

Duration measure(Function() f) {
  final start = DateTime.now();
  f();
  return DateTime.now().difference(start);
}