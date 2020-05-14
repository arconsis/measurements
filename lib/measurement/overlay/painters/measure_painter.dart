import 'dart:ui';

import 'package:flutter/material.dart' as material;
import 'package:measurements/util/colors.dart';
import 'package:measurements/util/logger.dart';

class MeasurePainter extends material.CustomPainter {
  final Logger _logger = Logger(LogDistricts.MEASURE_PAINTER);
  final Offset start, end;

  final Paint _drawPaint = Paint();

  MeasurePainter({@material.required this.start, @material.required this.end, Color paintColor}) {
    if (paintColor == null) {
      paintColor = Colors.drawColor;
    }

    _drawPaint.color = paintColor;
    _drawPaint.strokeWidth = 2.0;

    _logger.log("drawing from $start to $end");
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(start, 4, _drawPaint);
    canvas.drawCircle(end, 4, _drawPaint);

    canvas.drawLine(start, end, _drawPaint);
  }

  @override
  bool shouldRepaint(material.CustomPainter oldDelegate) {
    MeasurePainter old = oldDelegate as MeasurePainter;

    return old.start != start || old.end != end;
  }
}
