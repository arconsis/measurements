import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:measurements/point.dart';

class MeasurePainter extends CustomPainter {
  Point downPoint, upPoint;

  MeasurePainter({this.downPoint, this.upPoint});

  Color green = new Color(0xFFAADD22);
  Paint drawPaint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    if (downPoint != null) {
      drawPaint.color = green;
      canvas.drawCircle(downPoint.pos, 10, drawPaint);
    }

    if (upPoint != null) {
      drawPaint.color = green;
      canvas.drawCircle(upPoint.pos, 10, drawPaint);
    }

    if (downPoint != null && upPoint != null) {
      drawPaint.strokeWidth = 5.0;
      canvas.drawLine(downPoint.pos, upPoint.pos, drawPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
