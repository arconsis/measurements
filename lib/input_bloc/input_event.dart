import 'dart:ui';

import 'package:equatable/equatable.dart';

///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

abstract class InputEvent extends Equatable {
  final Offset position;

  InputEvent(this.position);

  @override
  List<Object> get props => [position];

  @override
  String toString() {
    return super.toString() + " position: $position";
  }
}

class InputDownEvent extends InputEvent {
  InputDownEvent(Offset position) : super(position);
}

class InputMoveEvent extends InputEvent {
  InputMoveEvent(Offset position) : super(position);
}

class InputUpEvent extends InputEvent {
  InputUpEvent(Offset position) : super(position);
}
