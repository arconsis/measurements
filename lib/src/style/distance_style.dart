/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'dart:ui';

import 'package:document_measure/src/util/colors.dart';


/// Style class for customizing the distances on the lines between two points.
///
/// [showTolerance] will show up as for example 10.0±0.1mm instead of 10.0mm
///
/// [numDecimalPlaces] will be used for both the distance and the tolerance, if displayed.
/// [numDecimalPlaces] = 2 => 9.98mm or 9.98±0.12mm
/// [numDecimalPlaces] = 3 => 9.987mm or 9.987±0.123mm
class DistanceStyle {
  final Color textColor;

  final int numDecimalPlaces;
  final bool showTolerance;

  const DistanceStyle({this.textColor = drawColor, this.numDecimalPlaces = 2, this.showTolerance = false});
}
