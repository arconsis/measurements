import 'dart:ui';

import 'package:flutter/material.dart' as material;

class MeasurePainter extends material.CustomPainter {
  final Color defaultColor = Color(0xFFAADD22);

  MeasurePainter({this.fromPoint, this.toPoint, this.paintColor, this.distance, this.showDistanceOnLine}) {
    if (paintColor == null) {
      paintColor = defaultColor;
    }

    drawPaint.color = paintColor;
    canPaint = this.fromPoint != null && this.toPoint != null;

    if (showDistanceOnLine) {
      // TODO text should not go out of screen
      ParagraphBuilder paragraphBuilder = ParagraphBuilder(
        ParagraphStyle(
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          maxLines: 1,
          fontSize: 20.0,
          fontStyle: FontStyle.normal,
        ),
      );
      paragraphBuilder.pushStyle(TextStyle(color: paintColor));
      paragraphBuilder.addText("${distance?.toStringAsFixed(2)} mm");
      _paragraph = paragraphBuilder.build();
      _paragraph.layout(ParagraphConstraints(width: 150.0));

      textPosition = fromPoint + (toPoint - fromPoint) / 2.0;
    }
  }

  final Offset fromPoint, toPoint;
  final double distance;
  final bool showDistanceOnLine;
  final Paint drawPaint = Paint();
  Color paintColor;
  Paragraph _paragraph;
  Offset textPosition;
  bool canPaint = false;

  @override
  void paint(Canvas canvas, Size size) {
    if (canPaint) {
      canvas.drawCircle(fromPoint, 10, drawPaint);
      canvas.drawCircle(toPoint, 10, drawPaint);

      drawPaint.strokeWidth = 5.0;
      canvas.drawLine(fromPoint, toPoint, drawPaint);

      if (showDistanceOnLine) {
        canvas.drawParagraph(_paragraph, textPosition);
      }
    }
  }

  @override
  bool shouldRepaint(material.CustomPainter oldDelegate) {
    MeasurePainter old = oldDelegate as MeasurePainter;

    return canPaint && old.fromPoint != fromPoint || old.toPoint != toPoint;
  }
}
