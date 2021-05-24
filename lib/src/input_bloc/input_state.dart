/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'dart:ui';

import 'package:equatable/equatable.dart';

abstract class InputState extends Equatable {
  @override
  List<Object> get props => [];
}

abstract class InputPositionalState extends InputState {
  final Offset position;

  InputPositionalState(this.position);

  @override
  List<Object> get props => [position];

  @override
  String toString() => super.toString() + ' position: $position';
}

class InputStandardState extends InputPositionalState {
  InputStandardState(Offset position) : super(position);
}

class InputEndedState extends InputPositionalState {
  InputEndedState(Offset position) : super(position);
}

class InputDeleteRegionState extends InputPositionalState {
  InputDeleteRegionState(Offset position) : super(position);
}

class InputDeleteState extends InputState {}

class InputEmptyState extends InputState {}
