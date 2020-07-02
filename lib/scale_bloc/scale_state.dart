import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

class GestureState extends Equatable {
  final Offset offset;
  final double scale;
  final Matrix4 transform;

  GestureState(this.offset, this.scale, this.transform);

  @override
  List<Object> get props => [offset, scale, transform];
}
