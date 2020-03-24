import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart' as material;
import 'package:measurements/util/colors.dart';


class DistancePainter extends material.CustomPainter {
  static final double twoPiDegree = 2 * pi / 360;
  final Offset position;
  final double distance;
  final double radians;
  Color drawColor;

  final Offset zeroPoint = Offset(0, 0);
  final Paint _drawPaint = Paint();
  Paragraph _paragraph;

  DistancePainter({this.position, this.distance, this.radians = 0, this.drawColor}) {
    if (drawColor == null) {
      drawColor = Colors.drawColor;
    }

    _drawPaint.color = drawColor;

    ParagraphBuilder paragraphBuilder = ParagraphBuilder(
      ParagraphStyle(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: 1,
        fontSize: 20.0,
        height: 0.5,
        fontStyle: FontStyle.normal,
      ),
    );
    paragraphBuilder.pushStyle(TextStyle(color: drawColor,),);
    paragraphBuilder.addText("${distance?.toStringAsFixed(2)} mm");

    _paragraph = paragraphBuilder.build();
    _paragraph.layout(ParagraphConstraints(width: 150.0));
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(position.dx, position.dy);
    canvas.rotate(radians);

    canvas.drawCircle(zeroPoint, 15, _drawPaint);
    canvas.drawParagraph(_paragraph, zeroPoint);
  }

  @override
  bool shouldRepaint(material.CustomPainter oldDelegate) {
    DistancePainter old = oldDelegate as DistancePainter;

    return distance != old.distance || position != old.position;
  }
}