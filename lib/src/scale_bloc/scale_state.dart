import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

class ScaleState extends Equatable {
  final Offset offset;
  final double scale;
  final Matrix4 transform;

  ScaleState(this.offset, this.scale, this.transform);

  @override
  List<Object> get props => [offset, scale, transform];

  @override
  String toString() {
    return super.toString() + ' offset: $offset, scale: $scale, transform:\n$transform';
  }
}
