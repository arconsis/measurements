import 'dart:ui';

import 'package:equatable/equatable.dart';

class DrawingHolder extends Equatable {
  final List<Offset> points;
  final List<double> distances;

  DrawingHolder(this.points, this.distances);

  @override
  String toString() {
    return super.toString() + " points: $points, distances: $distances";
  }

  @override
  List<Object> get props => [points, distances];
}