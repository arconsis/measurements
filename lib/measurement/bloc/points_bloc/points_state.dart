import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/gestures.dart';

abstract class PointsState extends Equatable {
}

class PointsEmptyState extends PointsState {
  @override
  List<Object> get props => null;
}

class PointsSingleState extends PointsState {
  final Offset point;

  PointsSingleState(this.point);

  @override
  List<Object> get props => [point];

  @override
  String toString() {
    return super.toString() + " point: $point";
  }
}

class PointsOnlyState extends PointsState {
  final List<Offset> points;

  PointsOnlyState(this.points);

  @override
  List<Object> get props => [points];

  @override
  String toString() {
    return super.toString() + " points: $points";
  }
}

class PointsAndDistanceState extends PointsState {
  final List<Offset> points;
  final List<double> distances;
  final Offset viewCenter;

  PointsAndDistanceState(this.points, this.distances, this.viewCenter);

  @override
  List<Object> get props => [points, distances, viewCenter];

  @override
  String toString() {
    return super.toString() + " points: $points -- distances: $distances -- viewCenter: $viewCenter";
  }
}

class PointsAndDistanceActiveState extends PointsAndDistanceState {
  final List<int> nullIndices;

  PointsAndDistanceActiveState(List<Offset> points, List<double> distances, Offset viewCenter, this.nullIndices) : super(points, distances, viewCenter);

  @override
  List<Object> get props => [points, distances, viewCenter, nullIndices];

  @override
  String toString() {
    return super.toString() + " -- nullIndex: $nullIndices";
  }
}