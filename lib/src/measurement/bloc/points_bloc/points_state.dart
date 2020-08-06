/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'dart:ui';

import 'package:document_measure/src/measurement/overlay/holder.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/gestures.dart';

abstract class PointsState extends Equatable {}

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
    return super.toString() + ' point: $point';
  }
}

class PointsOnlyState extends PointsState {
  final List<Offset> points;

  PointsOnlyState(this.points);

  @override
  List<Object> get props => [points];

  @override
  String toString() {
    return super.toString() + ' points: $points';
  }
}

class PointsAndDistanceState extends PointsState {
  final List<Holder> holders;
  final Offset viewCenter;
  final double tolerance;

  PointsAndDistanceState(this.holders, this.viewCenter, this.tolerance);

  @override
  List<Object> get props => [holders, viewCenter, tolerance];

  @override
  String toString() {
    return super.toString() +
        ' drawingHolder: $holders, viewCenter: $viewCenter, tolerance: $tolerance';
  }
}

class PointsAndDistanceActiveState extends PointsAndDistanceState {
  final List<int> nullIndices;

  PointsAndDistanceActiveState(List<Holder> holders, Offset viewCenter,
      double tolerance, this.nullIndices)
      : super(holders, viewCenter, tolerance);

  @override
  List<Object> get props => [holders, viewCenter, tolerance, nullIndices];

  @override
  String toString() {
    return super.toString() + ' nullIndex: $nullIndices';
  }
}
