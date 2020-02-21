import 'dart:math';

import 'package:flutter/material.dart';

class Point {
  Offset pos;

  Point({this.pos});

  Point operator -(other) {
    return Point(pos: pos - other.pos);
  }

  double length() {
    return sqrt(pos.dx * pos.dx + pos.dy * pos.dy);
  }

  @override
  String toString() {
    return "x: " + pos.dx.toString() + " y: " + pos.dy.toString();
  }
}
