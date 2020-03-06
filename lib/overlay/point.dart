import 'dart:math';

import 'package:flutter/material.dart';

class Point {
  Offset position;

  Point(this.position);

  Point operator -(Point other) {
    return Point(position - other.position);
  }

  double length() {
    return sqrt(position.dx * position.dx + position.dy * position.dy);
  }

  @override
  String toString() {
    return "x: " + position.dx.toString() + " y: " + position.dy.toString();
  }
}
