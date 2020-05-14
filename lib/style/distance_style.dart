import 'dart:ui';

import 'package:measurements/util/colors.dart';

class DistanceStyle {
  final Color textColor;

  final int numDecimalPlaces;

  const DistanceStyle({this.textColor = Colors.drawColor, this.numDecimalPlaces = 2});
}