import 'dart:ui';

import 'package:equatable/equatable.dart';

abstract class MeasureState extends Equatable {
}

class MeasureInactiveState extends MeasureState {
  @override
  List<Object> get props => null;
}

class MeasureActiveState extends MeasureState {
  final Offset position;
  final Image backgroundImage;
  final double imageScaleFactor;

  MeasureActiveState(this.position, {this.backgroundImage, this.imageScaleFactor});

  @override
  List<Object> get props => [position, backgroundImage, imageScaleFactor];

  @override
  String toString() {
    return super.toString() + " position: $position, backgroundImage: $backgroundImage, imageScaleFactor: $imageScaleFactor";
  }
}