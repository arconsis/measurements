import 'dart:ui';

import 'package:equatable/equatable.dart';

abstract class MeasurementState extends Equatable {
}

class MeasurementEmptyState extends MeasurementState {
  @override
  List<Object> get props => null;
}

class MeasurementOnlyPointsState extends MeasurementState {
  final List<Offset> points;

  MeasurementOnlyPointsState(this.points);

  @override
  List<Object> get props => [points];
}

class MeasurementPointsWithDistancesState extends MeasurementState {
  final List<Offset> points;
  final List<double> distances;

  MeasurementPointsWithDistancesState(this.points, this.distances);

  @override
  List<Object> get props => [points, distances];
}

class MeasurementEditingState extends MeasurementState {
  final Image backgroundImage;
  final Offset position;

  MeasurementEditingState(this.backgroundImage, this.position);

  @override
  List<Object> get props => [backgroundImage, position];
}