import 'dart:ui';

import 'package:flutter/material.dart' as material;
import 'package:measurements/util/colors.dart';

class MeasurePainter extends material.CustomPainter {
  MeasurePainter({this.fromPoint, this.toPoint, this.paintColor, this.distance, this.showDistanceOnLine}) {
    if (paintColor == null) {
      paintColor = Colors.drawColor;
    }

    drawPaint.color = paintColor;
  }

  final Offset fromPoint, toPoint;
  final double distance;
  final bool showDistanceOnLine;
  final Paint drawPaint = Paint();
  Color paintColor;
  Offset textPosition;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(fromPoint, 10, drawPaint);
    canvas.drawCircle(toPoint, 10, drawPaint);

    drawPaint.strokeWidth = 5.0;
    canvas.drawLine(fromPoint, toPoint, drawPaint);
  }

  @override
  bool shouldRepaint(material.CustomPainter oldDelegate) {
    MeasurePainter old = oldDelegate as MeasurePainter;

    return old.fromPoint != fromPoint || old.toPoint != toPoint;
  }
}
