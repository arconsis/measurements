/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'dart:ui';

import 'package:equatable/equatable.dart';

abstract class MagnificationState extends Equatable {}

class MagnificationInactiveState extends MagnificationState {
  @override
  List<Object> get props => [];
}

class MagnificationActiveState extends MagnificationState {
  final Offset position;
  final Offset absolutePosition;
  final Offset magnificationOffset;
  final Image backgroundImage;
  final double imageScaleFactor;

  MagnificationActiveState(this.position, this.magnificationOffset,
      {this.absolutePosition, this.backgroundImage, this.imageScaleFactor});

  @override
  List<Object> get props => [
        position,
        absolutePosition,
        magnificationOffset,
        backgroundImage,
        imageScaleFactor
      ];

  @override
  String toString() {
    return super.toString() +
        ' position: $position, absolutePosition: $absolutePosition, magnificationOffset: $magnificationOffset, backgroundImage: $backgroundImage, imageScaleFactor: $imageScaleFactor';
  }
}
