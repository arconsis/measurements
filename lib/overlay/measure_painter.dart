import 'dart:ui';

import 'package:flutter/material.dart' as material;
import 'package:measurements/util/colors.dart';

class MeasurePainter extends material.CustomPainter {
  final Offset start, end;

  final Paint _drawPaint = Paint();

  MeasurePainter({@material.required this.start, @material.required this.end, Color paintColor}) {
    if (paintColor == null) {
      paintColor = Colors.drawColor;
    }

    _drawPaint.color = paintColor;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(start, 10, _drawPaint);
    canvas.drawCircle(end, 10, _drawPaint);

    _drawPaint.strokeWidth = 5.0;
    canvas.drawLine(start, end, _drawPaint);
  }

  @override
  bool shouldRepaint(material.CustomPainter oldDelegate) {
    MeasurePainter old = oldDelegate as MeasurePainter;

    return old.start != start || old.end != end;
  }
}
