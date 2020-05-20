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
  final Offset magnificationOffset;
  final Image backgroundImage;
  final double imageScaleFactor;

  MeasureActiveState(this.position, this.magnificationOffset, {this.backgroundImage, this.imageScaleFactor});

  @override
  List<Object> get props => [position, magnificationOffset, backgroundImage, imageScaleFactor];

  @override
  String toString() {
    return super.toString() + " position: $position, magnificationOffset: $magnificationOffset, backgroundImage: $backgroundImage, imageScaleFactor: $imageScaleFactor";
  }
}