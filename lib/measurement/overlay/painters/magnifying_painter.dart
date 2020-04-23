import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:measurements/util/colors.dart' as c;
import 'package:measurements/util/logger.dart';

class MagnifyingPainter extends CustomPainter {
  final Logger logger = Logger(LogDistricts.MAGNIFYING_PAINTER);
  final double borderRadiusOffset = 2,
      fingerRadiusOffset = 50;

  final double radius;
  final Offset fingerPosition;
  final ui.Image image;

  Offset drawPosition;
  Paint drawPaint = Paint();

  RRect outerCircle, innerCircle;
  Rect imageTargetRect, imageSourceRect;

  MagnifyingPainter({@required this.fingerPosition, @required this.radius, @required this.image, double imageScaleFactor}) {
    drawPosition = fingerPosition + Offset(0, -(radius + fingerRadiusOffset));

    double diameter = 2 * radius;

    outerCircle = getCircle(drawPosition, radius + borderRadiusOffset);
    innerCircle = getCircle(drawPosition, radius);

    imageSourceRect = Rect.fromCenter(center: fingerPosition * imageScaleFactor, width: diameter, height: diameter);
    imageTargetRect = Rect.fromCenter(center: drawPosition, width: diameter, height: diameter);

    drawPaint.color = c.Colors.drawColor;
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
    canvas.clipRRect(outerCircle);
    canvas.drawImageRect(image, imageSourceRect, imageTargetRect, drawPaint);

    canvas.drawDRRect(outerCircle, innerCircle, drawPaint);
    canvas.drawLine(Offset(drawPosition.dx - radius, drawPosition.dy), Offset(drawPosition.dx + radius, drawPosition.dy), drawPaint);
    canvas.drawLine(Offset(drawPosition.dx, drawPosition.dy - radius), Offset(drawPosition.dx, drawPosition.dy + radius), drawPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    MagnifyingPainter old = oldDelegate as MagnifyingPainter;

    return old.fingerPosition != fingerPosition || old.image != image;
  }
}