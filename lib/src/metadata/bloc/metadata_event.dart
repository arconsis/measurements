/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'dart:ui' as ui;

import 'package:document_measure/document_measure.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

abstract class MetadataEvent extends Equatable {}

class MetadataBackgroundEvent extends MetadataEvent {
  final ui.Image backgroundImage;
  final Size size;

  MetadataBackgroundEvent(this.backgroundImage, this.size);

  @override
  List<Object> get props => [backgroundImage, size];

  @override
  String toString() {
    return super.toString() + ' size: $size, backgroundImage: $backgroundImage';
  }
}

class MetadataStartedEvent extends MetadataEvent {
  final bool measure;
  final bool showDistances;
  final MeasurementInformation measurementInformation;
  final MagnificationStyle magnificationStyle;
  final MeasurementController controller;

  MetadataStartedEvent({
    @required this.measure,
    @required this.showDistances,
    @required this.measurementInformation,
    @required this.magnificationStyle,
    @required this.controller,
  });

  @override
  List<Object> get props => [
        measurementInformation,
        controller,
        measure,
        showDistances,
        magnificationStyle,
      ];

  @override
  String toString() {
    return super.toString() +
        ' MeasurementInformation: $measurementInformation, measure: $measure, showDistances: $showDistances, magnificationStyle: $magnificationStyle';
  }
}

class MetadataOrientationEvent extends MetadataEvent {
  final Orientation orientation;

  MetadataOrientationEvent(this.orientation);

  @override
  List<Object> get props => [orientation];

  @override
  String toString() {
    return super.toString() + ' orientation: $orientation';
  }
}

class MetadataScreenSizeEvent extends MetadataEvent {
  final Size screenSize;

  MetadataScreenSizeEvent(this.screenSize);

  @override
  List<Object> get props => [screenSize];

  @override
  String toString() {
    return super.toString() + ' screenSize: $screenSize';
  }
}

class MetadataDeleteRegionEvent extends MetadataEvent {
  final Offset position;
  final Size deleteSize;

  MetadataDeleteRegionEvent(this.position, this.deleteSize);

  @override
  List<Object> get props => [position, deleteSize];

  @override
  String toString() {
    return super.toString() + ' position: $position, deleteSize: $deleteSize';
  }
}
