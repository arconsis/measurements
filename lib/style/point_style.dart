import 'dart:ui';

import 'package:measurements/util/colors.dart';

class PointStyle {
  final Color dotColor;
  final Color lineColor;

  final double dotRadius;
  final double lineWidth;

  const PointStyle({this.dotColor = Colors.drawColor, this.dotRadius = 4, this.lineColor = Colors.drawColor, this.lineWidth = 2});
}