import 'dart:ui';

import 'package:flutter/material.dart' as material;
import 'package:measurements/style/point_style.dart';
import 'package:measurements/util/logger.dart';

class MeasurePainter extends material.CustomPainter {
  final Logger _logger = Logger(LogDistricts.MEASURE_PAINTER);
  final Offset start, end;
  final PointStyle style;

  final Paint _dotPaint = Paint(),
      _pathPaint = Paint();

  Path _drawPath;
  double _dotRadius;

  MeasurePainter({@material.required this.start, @material.required this.end, @material.required this.style}) {
    _dotPaint.color = style.dotColor;
    _dotRadius = style.dotRadius;

    LineType lineType = style.lineType;
    _pathPaint.style = PaintingStyle.stroke;
    _drawPath = Path();
    _drawPath.moveTo(start.dx, start.dy);

    if (lineType is SolidLine) {
      _pathPaint.color = lineType.lineColor;
      _pathPaint.strokeWidth = lineType.lineWidth;

      _drawPath.lineTo(end.dx, end.dy);
    } else if (lineType is DashedLine) {
      _pathPaint.color = lineType.lineColor;
      _pathPaint.strokeWidth = lineType.dashWidth;

      double distance = (end - start).distance;

      Offset solidOffset = (end - start) * lineType.dashLength / distance;
      Offset emptyOffset = (end - start) * lineType.dashDistance / distance;
      Offset currentPosition = start;

      int numLines = (distance / (lineType.dashLength + lineType.dashDistance)).floor();

      for (int i = 0; i < numLines; i++) {
        currentPosition += solidOffset;
        _drawPath.lineTo(currentPosition.dx, currentPosition.dy);
        currentPosition += emptyOffset;
        _drawPath.moveTo(currentPosition.dx, currentPosition.dy);
      }

      currentPosition += solidOffset;

      if ((currentPosition - start).distance > distance) {
        _drawPath.lineTo(end.dx, end.dy);
      } else {
        _drawPath.lineTo(currentPosition.dx, currentPosition.dy);
      }
    } else {
      throw UnimplementedError("This line type is not supported! Type was: $style");
    }

    _logger.log("drawing from $start to $end");
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(start, _dotRadius, _dotPaint);
    canvas.drawCircle(end, _dotRadius, _dotPaint);

    canvas.drawPath(_drawPath, _pathPaint);
  }

  @override
  bool shouldRepaint(material.CustomPainter oldDelegate) {
    MeasurePainter old = oldDelegate as MeasurePainter;

    return old.start != start || old.end != end || old.style != style;
  }
}
