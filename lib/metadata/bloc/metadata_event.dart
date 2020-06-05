///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

import 'dart:ui' as ui;

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:measurements/measurements.dart';
import 'package:measurements/style/magnification_style.dart';

abstract class MetadataEvent extends Equatable {
}

class MetadataBackgroundEvent extends MetadataEvent {
  final ui.Image backgroundImage;
  final Size size;

  MetadataBackgroundEvent(this.backgroundImage, this.size);

  @override
  List<Object> get props => [backgroundImage, size];

  @override
  String toString() {
    return super.toString() + " size: $size -- backgroundImage: $backgroundImage";
  }
}

class MetadataStartedEvent extends MetadataEvent {
  final bool measure;
  final double zoom;
  final bool showDistances;
  final MeasurementInformation measurementInformation;
  final MagnificationStyle magnificationStyle;

  final Function(List<double>) callback;
  final Function(double) toleranceCallback;

  MetadataStartedEvent({
    @required this.measurementInformation,
    @required this.zoom,
    @required this.measure,
    @required this.showDistances,
    @required this.magnificationStyle,
    @required this.callback,
    @required this.toleranceCallback
  });

  @override
  List<Object> get props => [measurementInformation, callback, toleranceCallback, zoom, measure, showDistances, magnificationStyle];

  @override
  String toString() {
    return super.toString() + " MeasurementInformation: $measurementInformation -- zoom: $zoom -- measure: $measure -- showDistances: $showDistances -- magnificationStyle: $magnificationStyle";
  }
}

class MetadataUpdatedEvent extends MetadataEvent {
  final bool measure;

  MetadataUpdatedEvent(this.measure);

  @override
  List<Object> get props => [measure];

  @override
  String toString() {
    return super.toString() + " measure: $measure";
  }
}