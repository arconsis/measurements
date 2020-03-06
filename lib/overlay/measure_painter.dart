import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:measurements/overlay/point.dart';

class MeasurePainter extends CustomPainter {
  final Color defaultColor = Color(0xFFAADD22);

  MeasurePainter({this.fromPoint, this.toPoint, this.paintColor}) {
    if (paintColor == null) {
      paintColor = defaultColor;
    }

    drawPaint.color = paintColor;
  }

  Point fromPoint, toPoint;
  Color paintColor;
  Paint drawPaint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(fromPoint.position, 10, drawPaint);
    canvas.drawCircle(toPoint.position, 10, drawPaint);

    drawPaint.strokeWidth = 5.0;
    canvas.drawLine(fromPoint.position, toPoint.position, drawPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
