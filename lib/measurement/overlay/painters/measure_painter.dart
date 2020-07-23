/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'dart:ui';

import 'package:flutter/material.dart' as material;
import 'package:measurements/style/point_style.dart';

class MeasurePainter extends material.CustomPainter {
  final Offset start, end;
  final PointStyle style;
  final Paint dotPaint, pathPaint;

  final Path _drawPath = Path();
  double _dotRadius;

  MeasurePainter({@material.required this.start, @material.required this.end, @material.required this.style, @material.required this.dotPaint, @material.required this.pathPaint}) {
    _dotRadius = style.dotRadius;

    LineType lineType = style.lineType;
    _drawPath.reset();
    _drawPath.moveTo(start.dx, start.dy);

    if (lineType is SolidLine) {
      _drawPath.lineTo(end.dx, end.dy);
    } else if (lineType is DashedLine) {
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
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(start, _dotRadius, dotPaint);
    canvas.drawCircle(end, _dotRadius, dotPaint);

    canvas.drawPath(_drawPath, pathPaint);
  }

  @override
  bool shouldRepaint(material.CustomPainter oldDelegate) {
    MeasurePainter old = oldDelegate as MeasurePainter;

    return old.start != start || old.end != end || old.style != style;
  }
}
