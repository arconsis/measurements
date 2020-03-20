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
    canPaint = this.fromPoint != null && this.toPoint != null;
  }

  final Point fromPoint, toPoint;
  final Paint drawPaint = Paint();
  Color paintColor;
  bool canPaint = false;

  @override
  void paint(Canvas canvas, Size size) {
    if (canPaint) {
      canvas.drawCircle(fromPoint.position, 10, drawPaint);
      canvas.drawCircle(toPoint.position, 10, drawPaint);

      drawPaint.strokeWidth = 5.0;
      canvas.drawLine(fromPoint.position, toPoint.position, drawPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    MeasurePainter old = oldDelegate as MeasurePainter;

    return canPaint && old.fromPoint != fromPoint || old.toPoint != toPoint;
  }
}
