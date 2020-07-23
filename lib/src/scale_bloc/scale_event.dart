import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

abstract class ScaleEvent {}

class ScaleDoubleTapEvent extends ScaleEvent {}

class ScaleOriginalEvent extends ScaleEvent {}

class ScaleResetEvent extends ScaleEvent {}

class ScaleCenterUpdatedEvent extends ScaleEvent {}

abstract class ScalePositionEvent extends ScaleEvent implements Equatable {
  final Offset position;

  ScalePositionEvent(this.position);

  @override
  bool get stringify => false;
}

class ScaleStartEvent extends ScalePositionEvent {
  ScaleStartEvent(Offset position) : super(position);

  @override
  List<Object> get props => [position];
}

class ScaleUpdateEvent extends ScalePositionEvent {
  final double scale;

  ScaleUpdateEvent(Offset position, this.scale) : super(position);

  @override
  List<Object> get props => [position, scale];
}
