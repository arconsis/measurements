///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

import 'dart:ui';

import 'package:equatable/equatable.dart';

abstract class MeasureEvent extends Equatable {
  final Offset position;

  MeasureEvent(this.position);

  @override
  List<Object> get props => [position];

  @override
  String toString() {
    return super.toString() + " position: $position";
  }
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

