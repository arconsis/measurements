import 'dart:ui';

import 'package:equatable/equatable.dart';

abstract class PointsState extends Equatable {
}

class PointsEmptyState extends PointsState {
  @override
  List<Object> get props => null;
}

class PointsOnlyState extends PointsState {
  final List<Offset> points;

  PointsOnlyState(this.points);

  @override
  List<Object> get props => [points];
}

class PointsAndDistanceState extends PointsState {
  final List<Offset> points;
  final List<double> distances;
  final Offset viewCenter;

  PointsAndDistanceState(this.points, this.distances, this.viewCenter);

  @override
  List<Object> get props => [points, distances, viewCenter];
}