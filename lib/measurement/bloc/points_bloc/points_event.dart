import 'dart:ui';

import 'package:equatable/equatable.dart';

abstract class PointsEvent extends Equatable {
  final List<Offset> points;

  PointsEvent(this.points);

  @override
  List<Object> get props => [points];

  @override
  String toString() {
    return super.toString() + " points: $points";
  }
}

class PointsOnlyEvent extends PointsEvent {
  PointsOnlyEvent(List<Offset> points) : super(points);
}

class PointsAndDistancesEvent extends PointsEvent {
  final List<double> distances;

  PointsAndDistancesEvent(List<Offset> points, this.distances) : super(points);

  @override
  List<Object> get props => [points, distances];

  @override
  String toString() {
    return super.toString() + " points: $points -- distances: $distances";
  }
}