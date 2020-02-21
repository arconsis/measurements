import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:measurements/point.dart';

class MeasurePainter extends CustomPainter {
  Point fromPoint, toPoint;

  MeasurePainter({this.fromPoint, this.toPoint});

  Color green = Color(0xFFAADD22);
  Paint drawPaint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    if (fromPoint != null) {
      drawPaint.color = green;
      canvas.drawCircle(fromPoint.pos, 10, drawPaint);
    }

    if (toPoint != null) {
      drawPaint.color = green;
      canvas.drawCircle(toPoint.pos, 10, drawPaint);
    }

    if (fromPoint != null && toPoint != null) {
      drawPaint.strokeWidth = 5.0;
      canvas.drawLine(fromPoint.pos, toPoint.pos, drawPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
