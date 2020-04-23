import 'dart:ui' as ui;

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

abstract class MetadataEvent extends Equatable {
}

class MetadataOrientationEvent extends MetadataEvent {
  final Orientation orientation;

  MetadataOrientationEvent(this.orientation);

  @override
  List<Object> get props => [orientation];
}

class MetadataBackgroundEvent extends MetadataEvent {
  final ui.Image backgroundImage;
  final double width;

  MetadataBackgroundEvent(this.backgroundImage, this.width);

  @override
  List<Object> get props => [backgroundImage, width];
}

class MetadataStartedEvent extends MetadataEvent {
  final Size documentSize;
  final Function(List<double>) callback;
  final double scale;
  final double zoom;
  final bool measure;
  final bool showDistances;
  final Color lineColor;

  MetadataStartedEvent(this.documentSize, this.callback, this.scale, this.zoom, this.measure, this.showDistances, this.lineColor);

  @override
  List<Object> get props => [documentSize, callback, scale, zoom, measure, showDistances, lineColor];
}

class MetadataUpdatedEvent extends MetadataEvent {
  final bool measure;

  MetadataUpdatedEvent(this.measure);

  @override
  List<Object> get props => [measure];
}