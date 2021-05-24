/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'dart:ui' as ui;

import 'package:document_measure/src/style/magnification_style.dart';
import 'package:flutter/material.dart';

class MagnifyingPainter extends CustomPainter {
  final Offset fingerPosition;
  final ui.Image image;
  final MagnificationStyle style;

  final _drawPaint = Paint();

  Offset _drawPosition;
  RRect _outerCircle, _innerCircle;
  Rect _imageTargetRect, _imageSourceRect;

  MagnifyingPainter(
      {@required this.fingerPosition,
      @required Offset absolutePosition,
      @required this.image,
      @required this.style,
      double imageScaleFactor,
      @required Offset magnificationOffset}) {
    _drawPosition = fingerPosition - magnificationOffset;

    var diameter = 2 * style.magnificationRadius;

    _innerCircle = getCircle(_drawPosition, style.magnificationRadius);
    _outerCircle = _innerCircle.inflate(style.outerCircleThickness);

    _imageSourceRect = Rect.fromCenter(
        center: absolutePosition * imageScaleFactor,
        width: diameter,
        height: diameter);
    _imageTargetRect = Rect.fromCenter(
        center: _drawPosition, width: diameter, height: diameter);

    _drawPaint.color = style.magnificationColor;
    _drawPaint.strokeWidth = style.crossHairThickness;
  }

  RRect getCircle(Offset position, double radius) {
    return RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: position, width: radius * 2, height: radius * 2),
        Radius.circular(radius));
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRRect(_outerCircle);
    canvas.drawImageRect(image, _imageSourceRect, _imageTargetRect, _drawPaint);

    canvas.drawDRRect(_outerCircle, _innerCircle, _drawPaint);
    canvas.drawLine(
        Offset(_drawPosition.dx - style.magnificationRadius, _drawPosition.dy),
        Offset(_drawPosition.dx + style.magnificationRadius, _drawPosition.dy),
        _drawPaint);
    canvas.drawLine(
        Offset(_drawPosition.dx, _drawPosition.dy - style.magnificationRadius),
        Offset(_drawPosition.dx, _drawPosition.dy + style.magnificationRadius),
        _drawPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    var old = oldDelegate as MagnifyingPainter;

    return old.fingerPosition != fingerPosition || old.image != image;
  }
}
