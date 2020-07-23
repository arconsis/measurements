/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'dart:ui';

import 'package:measurements/util/colors.dart';

/// Style class for customizing the appearance of the magnification glass.
///
/// [magnificationColor] will be used for all lines and circles of the magnification glass.
///
/// [magnificationRadius] is the inner radius of the outer circle around the magnified image.
///
/// [outerCircleThickness] is added to the [magnificationRadius] and gives to total radius of the rendered magnification glass.
class MagnificationStyle {
  final Color magnificationColor;

  final double magnificationRadius;
  final double outerCircleThickness;
  final double crossHairThickness;

  const MagnificationStyle({this.magnificationColor = drawColor, this.magnificationRadius = 50, this.outerCircleThickness = 2, this.crossHairThickness = 0.0});
}
