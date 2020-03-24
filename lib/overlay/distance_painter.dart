import 'dart:ui';

import 'package:flutter/material.dart' as material;
import 'package:measurements/util/colors.dart';


class DistancePainter extends material.CustomPainter {
  final Offset position;
  final double distance;
  Color drawColor;

  final Paint _drawPaint = Paint();
  Paragraph _paragraph;

  DistancePainter({this.position, this.distance, this.drawColor}) {
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
    canvas.drawCircle(position, 15, _drawPaint);
    canvas.drawParagraph(_paragraph, position);
  }

  @override
  bool shouldRepaint(material.CustomPainter oldDelegate) {
    DistancePainter old = oldDelegate as DistancePainter;

    return distance != old.distance || position != old.position;
  }
}