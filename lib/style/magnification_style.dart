///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

import 'dart:ui';

import 'package:measurements/util/colors.dart';

class MagnificationStyle {
  final Color magnificationColor;

  final double magnificationRadius;
  final double outerCircleThickness;
  final double crossHairThickness;

  const MagnificationStyle({this.magnificationColor = Colors.drawColor, this.magnificationRadius = 50, this.outerCircleThickness = 2, this.crossHairThickness = 0.0});
}