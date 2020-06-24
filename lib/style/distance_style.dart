///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

import 'dart:ui';

import 'package:measurements/util/colors.dart';

class DistanceStyle {
  final Color textColor;

  final int numDecimalPlaces;
  final bool showTolerance;

  const DistanceStyle({this.textColor = drawColor, this.numDecimalPlaces = 2, this.showTolerance = false});
}