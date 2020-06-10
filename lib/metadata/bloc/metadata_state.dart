///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:photo_view/photo_view.dart';

class MetadataState extends Equatable {
  final PhotoViewController controller;
  final bool measure;
  final double zoom;
  final Orientation orientation;

  MetadataState(this.controller, this.measure, this.zoom, this.orientation);

  @override
  List<Object> get props => [controller, measure, zoom, this.orientation];

  @override
  String toString() {
    return super.toString() + " PhotoViewController: $controller, measure: $measure, zoom: $zoom, orientation: $orientation";
  }
}