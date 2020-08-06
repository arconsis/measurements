/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';

import 'logger.dart';

extension IterableExtension on Iterable {
  void doInBetween<T>(Function(T, T) function) {
    var iterator = this.iterator;
    iterator.moveNext();

    T current = iterator.current, next;

    while (iterator.moveNext()) {
      next = iterator.current;

      function(current, next);

      current = next;
    }
  }

  void zip<T, K>(Iterable<T> iterable, Function(K, T) function) {
    Iterator thisIterator = iterator, otherIterator = iterable.iterator;

    while (thisIterator.moveNext() && otherIterator.moveNext()) {
      K thisCurrent = thisIterator.current;
      T otherCurrent = otherIterator.current;

      function(thisCurrent, otherCurrent);
    }
  }
}

extension NumberExtension on num {
  bool isInBounds(num lower, num upper) => this > lower && this < upper;

  num fit(num lower, num upper) => min(max(lower, this), upper);
}

extension OffsetExtension on Offset {
  Offset fitInto(Size mySize, Size bounds, Offset offset, Offset target,
      double threshold, double scale) {
    var currentOffset = this + offset;
    var thresholdOffset = min(mySize.width, mySize.height) * threshold;

    return Offset(
        (currentOffset.dx + target.dx).fit(
            -mySize.width + thresholdOffset, bounds.width - thresholdOffset),
        (currentOffset.dy + target.dy).fit(
            -mySize.height + thresholdOffset, bounds.height - thresholdOffset));
  }
}

void measure(Logger logger, String text, Function() f) {
  final start = DateTime.now();
  f();
  logger.log(text + DateTime.now().difference(start).toString());
}
