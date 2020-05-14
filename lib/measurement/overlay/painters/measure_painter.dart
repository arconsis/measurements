import 'dart:ui';

import 'package:flutter/material.dart' as material;
import 'package:measurements/style/point_style.dart';
import 'package:measurements/util/logger.dart';

class MeasurePainter extends material.CustomPainter {
  final Logger _logger = Logger(LogDistricts.MEASURE_PAINTER);
  final Offset start, end;

  final Paint _dotPaint = Paint(),
      _linePaint = Paint();
  double _dotRadius;

  MeasurePainter({@material.required this.start, @material.required this.end, @material.required PointStyle style}) {
    _dotPaint.color = style.dotColor;
    _dotRadius = style.dotRadius;

    _linePaint.color = style.lineColor;
    _linePaint.strokeWidth = style.lineWidth;

    _logger.log("drawing from $start to $end");
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(start, _dotRadius, _dotPaint);
    canvas.drawCircle(end, _dotRadius, _dotPaint);

    canvas.drawLine(start, end, _linePaint);
  }

  @override
  bool shouldRepaint(material.CustomPainter oldDelegate) {
    MeasurePainter old = oldDelegate as MeasurePainter;

    return old.start != start || old.end != end;
  }
}
