///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

import 'package:equatable/equatable.dart';

class MetadataState extends Equatable {
  final bool measure;
  final double zoom;
  final double maxZoom;

  MetadataState(this.measure, this.zoom, this.maxZoom);

  @override
  List<Object> get props => [measure, zoom, maxZoom];

  @override
  String toString() {
    return super.toString() + " measure: $measure, zoom: $zoom, maxZoom: $maxZoom";
  }
}
