/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'dart:ui';

import 'package:equatable/equatable.dart';

abstract class MagnificationEvent extends Equatable {}

class MagnificationShowEvent extends MagnificationEvent {
  final Offset position;

  MagnificationShowEvent(this.position);

  @override
  List<Object> get props => [position];

  @override
  String toString() {
    return super.toString() + ' position: $position';
  }
}

class MagnificationHideEvent extends MagnificationEvent {
  @override
  List<Object> get props => [];
}
