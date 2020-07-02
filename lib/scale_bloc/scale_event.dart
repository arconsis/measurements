import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

abstract class GestureEvent extends Equatable {
  final Offset position;

  GestureEvent(this.position);
}

class GestureScaleStartEvent extends GestureEvent {
  GestureScaleStartEvent(Offset position) : super(position);

  @override
  List<Object> get props => [position];
}

class GestureScaleUpdateEvent extends GestureEvent {
  final double scale;

  GestureScaleUpdateEvent(Offset position, this.scale) : super(position);

  @override
  List<Object> get props => [position, scale];
}
