import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:measurements/util/logger.dart';

class MagnifyingPainter extends CustomPainter {
  final Logger logger = Logger(LogDistricts.MAGNIFYING_PAINTER);
  final Offset fingerPosition, center;
  final Size viewSize;
  final ui.Image image;

  Offset drawPosition;
  Paint drawPaint = Paint();

  MagnifyingPainter({@required this.fingerPosition, @required this.center, @required this.viewSize, @required this.image}) {
    if (fingerPosition.dx > center.dx) {
      drawPosition = Offset(viewSize.width / 4, viewSize.height / 10);
    } else {
      drawPosition = Offset(viewSize.width * 3 / 4, viewSize.height / 10);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, drawPosition, drawPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    MagnifyingPainter old = oldDelegate as MagnifyingPainter;

    return old.fingerPosition != fingerPosition || old.image != image;
  }

}