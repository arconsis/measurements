import 'dart:ui';

import 'package:equatable/equatable.dart';

abstract class PointsEvent extends Equatable {}

class PointsOnlyEvent extends PointsEvent {
  final List<Offset> points;

  PointsOnlyEvent(this.points);

  @override
  List<Object> get props => [points];
}

class PointsAndDistancesEvent extends PointsEvent {
  final List<Offset> points;
  final List<double> distances;

  PointsAndDistancesEvent(this.points, this.distances);

  @override
  List<Object> get props => [points, distances];
}