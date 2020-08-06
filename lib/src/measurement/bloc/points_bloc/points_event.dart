/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:document_measure/document_measure.dart';

abstract class PointsEvent extends Equatable {
  final List<Offset> points;

  PointsEvent(this.points);

  @override
  List<Object> get props => [points];

  @override
  String toString() {
    return super.toString() + ' points: $points';
  }
}

class PointsOnlyEvent extends PointsEvent {
  PointsOnlyEvent(List<Offset> points) : super(points);
}

class PointsAndDistancesEvent extends PointsEvent {
  final List<LengthUnit> distances;

  PointsAndDistancesEvent(List<Offset> points, this.distances) : super(points);

  @override
  List<Object> get props => [points, distances];

  @override
  String toString() {
    return super.toString() + ' distances: $distances';
  }
}