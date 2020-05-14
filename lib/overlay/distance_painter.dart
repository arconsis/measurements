import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart' as material;
import 'package:measurements/util/colors.dart';
import 'package:measurements/util/logger.dart';

//1432: how do you delete the points? -> not implemented yet
// bug when keeping mouse pressed. This one is also a widget. -> CustomPainter isn't a widget
// Calculations could be in the bloc to test them. -> Bloc should only be in widgets I guess, this is not a widget.
class DistancePainter extends material.CustomPainter {
  final Logger logger = Logger(LogDistricts.DISTANCE_PAINTER);

  final double distance;
  final double width, height;

  Offset _zeroPoint = Offset(-24, 0);
  final double _offsetPerDigit = 4.57;

  Paragraph _paragraph;
  double _radians;
  Offset _position;

  DistancePainter(
      {@material.required Offset start,
      @material.required Offset end,
      @material.required this.distance,
      @material.required this.width,
      @material.required this.height,
      Color drawColor}) {
    if (drawColor == null) {
      drawColor = Colors.drawColor;
    }

    if (distance > 0) {
      _zeroPoint -=
          Offset(((log(distance) / log(10)).floor() - 1) * _offsetPerDigit, 0);
    }

    Offset center = Offset(width / 2.0, height / 2.0);

    Offset difference = end - start;
    _position = start + difference / 2.0;
    _radians = difference.direction;

    if (_radians.abs() >= pi / 2.0) {
      _radians += pi;
    }

    Offset positionToCenter = center - _position;

    Offset offset = difference.normal();
    offset *= offset.cosAlpha(positionToCenter).sign;

    ParagraphBuilder paragraphBuilder = ParagraphBuilder(
      ParagraphStyle(
        textAlign: TextAlign.start,
        textDirection: TextDirection.ltr,
        maxLines: 1,
        height: 0.5,
        fontStyle: FontStyle.normal,
      ),
    );
    paragraphBuilder.pushStyle(
      TextStyle(color: drawColor),
    );
    paragraphBuilder.addText("${distance?.toStringAsFixed(2)} mm");

    _paragraph = paragraphBuilder.build();
    _paragraph.layout(ParagraphConstraints(width: 300));

    _position += offset * 12;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(_position.dx, _position.dy);
    canvas.rotate(_radians);

    canvas.drawParagraph(_paragraph, _zeroPoint);
  }

  @override
  bool shouldRepaint(material.CustomPainter oldDelegate) {
    DistancePainter old = oldDelegate as DistancePainter;

    return distance != old.distance || _position != old._position;
  }
}

extension OffsetExtension on Offset {
  Offset normal() {
    Offset normalized = this.normalize();
    return Offset(-normalized.dy, normalized.dx);
  }

  Offset normalize() {
    return this / this.distance;
  }

  double cosAlpha(Offset other) {
    Offset thisNormalized = this.normalize();
    Offset otherNormalized = other.normalize();

    return thisNormalized.dx * otherNormalized.dx +
        thisNormalized.dy * otherNormalized.dy;
  }
}
