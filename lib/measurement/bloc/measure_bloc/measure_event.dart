import 'dart:ui';

import 'package:equatable/equatable.dart';

abstract class MeasureEvent extends Equatable {
  final Offset position;

  MeasureEvent(this.position);

  @override
  List<Object> get props => [position];
}

class MeasureDownEvent extends MeasureEvent {
  MeasureDownEvent(Offset position) : super(position);
}

class MeasureMoveEvent extends MeasureEvent {
  MeasureMoveEvent(Offset position) : super(position);
}

class MeasureUpEvent extends MeasureEvent {
  MeasureUpEvent(Offset position) : super(position);
}

