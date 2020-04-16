import 'dart:ui';

import 'package:equatable/equatable.dart';

abstract class MeasurementEvent extends Equatable {}

class MeasurementUpdatedEvent extends MeasurementEvent {
  final List<Offset> points;
  final List<double> distances;
  final bool showDistances;

  MeasurementUpdatedEvent(this.points, this.distances, this.showDistances);

  @override
  List<Object> get props => [points, distances, showDistances];
}

abstract class MeasurementUserEvent extends MeasurementEvent {
  final Offset position;

  MeasurementUserEvent({this.position});

  @override
  List<Object> get props => [position];
}

class MeasurementDownEvent extends MeasurementUserEvent {}

class MeasurementMoveEvent extends MeasurementUserEvent {}

class MeasurementUpEvent extends MeasurementUserEvent {}

