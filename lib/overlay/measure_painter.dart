import 'dart:ui';

import 'package:flutter/material.dart' as material;
import 'package:measurements/overlay/Holder.dart';
import 'package:measurements/util/colors.dart';
import 'package:measurements/util/logger.dart';

class MeasurePainter extends material.CustomPainter {
  final Logger logger = Logger(LogDistricts.MEASURE_PAINTER);
  final List<Holder> pointHolders;

  final Paint _drawPaint = Paint();

  MeasurePainter({@material.required this.pointHolders, Color paintColor}) {
    if (paintColor == null) {
      paintColor = Colors.drawColor;
    }

    _drawPaint.color = paintColor;
    _drawPaint.strokeWidth = 5.0;

    logger.log("drawing points: $pointHolders");
  }

  @override
  void paint(Canvas canvas, Size size) {
    Holder currentHolder;

    for (int i = 0; i < pointHolders.length; i++) {
      currentHolder = pointHolders[i];

      canvas.drawCircle(currentHolder.start, 10, _drawPaint);
      canvas.drawCircle(currentHolder.end, 10, _drawPaint);

      canvas.drawLine(currentHolder.start, currentHolder.end, _drawPaint);
    }
  }

  @override
  bool shouldRepaint(material.CustomPainter oldDelegate) {
    MeasurePainter old = oldDelegate as MeasurePainter;

    return old.pointHolders.length != pointHolders.length || old.pointHolders != pointHolders;
  }
}
