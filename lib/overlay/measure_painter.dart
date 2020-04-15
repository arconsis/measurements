import 'dart:ui';

import 'package:flutter/material.dart' as material;
import 'package:measurements/util/colors.dart';
import 'package:measurements/util/logger.dart';

//132: how do you delete the points? bug when keeping mouse pressed. This one is also a widget. Calculations could be in the bloc.
class MeasurePainter extends material.CustomPainter {
  final Logger logger = Logger(LogDistricts.MEASURE_PAINTER);
  final Offset start, end;

  final Paint _drawPaint = Paint();

  MeasurePainter(
      {@material.required this.start,
      @material.required this.end,
      Color paintColor}) {
    if (paintColor == null) {
      paintColor = Colors.drawColor;
    }

    _drawPaint.color = paintColor;

    logger.log("drawing from $start to $end");
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
