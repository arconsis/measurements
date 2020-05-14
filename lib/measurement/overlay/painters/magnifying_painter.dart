import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:measurements/util/colors.dart' as c;
import 'package:measurements/util/logger.dart';

class MagnifyingPainter extends CustomPainter {
  final Logger _logger = Logger(LogDistricts.MAGNIFYING_PAINTER);
  final double _borderRadiusOffset = 2,
      _fingerRadiusOffset = 50;

  final double radius;
  final Offset fingerPosition;
  final ui.Image image;

  Offset _drawPosition;
  Paint _drawPaint = Paint();

  RRect _outerCircle, _innerCircle;
  Rect _imageTargetRect, _imageSourceRect;

  MagnifyingPainter({@required this.fingerPosition, @required this.radius, @required this.image, double imageScaleFactor}) {
    _drawPosition = fingerPosition + Offset(0, -(radius + _fingerRadiusOffset));

    double diameter = 2 * radius;

    _outerCircle = getCircle(_drawPosition, radius + _borderRadiusOffset);
    _innerCircle = getCircle(_drawPosition, radius);

    _imageSourceRect = Rect.fromCenter(center: fingerPosition * imageScaleFactor, width: diameter, height: diameter);
    _imageTargetRect = Rect.fromCenter(center: _drawPosition, width: diameter, height: diameter);

    _drawPaint.color = c.Colors.drawColor;
  }

  RRect getCircle(Offset position, double radius) {
    return RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: position,
            width: radius * 2,
            height: radius * 2
        ),
        Radius.circular(radius)
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRRect(_outerCircle);
    canvas.drawImageRect(image, _imageSourceRect, _imageTargetRect, _drawPaint);

    canvas.drawDRRect(_outerCircle, _innerCircle, _drawPaint);
    canvas.drawLine(Offset(_drawPosition.dx - radius, _drawPosition.dy), Offset(_drawPosition.dx + radius, _drawPosition.dy), _drawPaint);
    canvas.drawLine(Offset(_drawPosition.dx, _drawPosition.dy - radius), Offset(_drawPosition.dx, _drawPosition.dy + radius), _drawPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    MagnifyingPainter old = oldDelegate as MagnifyingPainter;

    return old.fingerPosition != fingerPosition || old.image != image;
  }
}