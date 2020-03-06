import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:measurements/point.dart';

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
    if (fromPoint != null) {
      canvas.drawCircle(fromPoint.pos, 10, drawPaint);
    }

    if (toPoint != null) {
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
