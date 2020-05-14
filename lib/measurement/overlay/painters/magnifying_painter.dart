import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:measurements/style/magnification_style.dart';
import 'package:measurements/util/logger.dart';

class MagnifyingPainter extends CustomPainter {
  final Logger _logger = Logger(LogDistricts.MAGNIFYING_PAINTER);
  final double _fingerRadiusOffset = 50;

  final Offset fingerPosition;
  final ui.Image image;
  final MagnificationStyle style;

  Paint _drawPaint = Paint();

  Offset _drawPosition;
  RRect _outerCircle, _innerCircle;
  Rect _imageTargetRect, _imageSourceRect;

  MagnifyingPainter({@required this.fingerPosition, @required this.image, @required this.style, double imageScaleFactor}) {
    _drawPosition = fingerPosition + Offset(0, -(style.magnificationRadius + _fingerRadiusOffset));

    double diameter = 2 * style.magnificationRadius;

    _outerCircle = getCircle(_drawPosition, style.magnificationRadius + style.outerCircleThickness);
    _innerCircle = getCircle(_drawPosition, style.magnificationRadius);

    _imageSourceRect = Rect.fromCenter(center: fingerPosition * imageScaleFactor, width: diameter, height: diameter);
    _imageTargetRect = Rect.fromCenter(center: _drawPosition, width: diameter, height: diameter);

    _drawPaint.color = style.magnificationColor;
    _drawPaint.strokeWidth = style.crossHairThickness;
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
    canvas.drawLine(Offset(_drawPosition.dx - style.magnificationRadius, _drawPosition.dy), Offset(_drawPosition.dx + style.magnificationRadius, _drawPosition.dy), _drawPaint);
    canvas.drawLine(Offset(_drawPosition.dx, _drawPosition.dy - style.magnificationRadius), Offset(_drawPosition.dx, _drawPosition.dy + style.magnificationRadius), _drawPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    MagnifyingPainter old = oldDelegate as MagnifyingPainter;

    return old.fingerPosition != fingerPosition || old.image != image;
  }
}