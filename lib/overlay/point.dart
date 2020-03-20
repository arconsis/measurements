import 'package:flutter/material.dart';

class Point {
  Offset position;

  Point(this.position);

  Point operator -(Point other) {
    return Point(position - other.position);
  }

  double length() {
    return position.distance;
  }

  @override
  String toString() {
    return "Point(x: ${position.dx.toStringAsFixed(2)} y: ${position.dy.toStringAsFixed(2)}";
  }

  @override
  bool operator ==(other) {
    return position == other;
  }

  @override
  int get hashCode => position.hashCode;
}
