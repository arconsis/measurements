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
  final double magnificationRadius;

  MeasureActiveState(this.position, this.backgroundImage, this.imageScaleFactor, this.magnificationRadius);

  @override
  List<Object> get props => [position, backgroundImage, imageScaleFactor, magnificationRadius];
}