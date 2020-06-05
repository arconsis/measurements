///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

import 'logger.dart';

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

void measure(Logger logger, String text, Function() f) {
  final start = DateTime.now();
  f();
  logger.log(text + DateTime.now().difference(start).toString());
}