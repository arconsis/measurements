import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart' as material;
import 'package:measurements/measurements.dart';
import 'package:measurements/style/distance_style.dart';
import 'package:measurements/util/logger.dart';


class DistancePainter extends material.CustomPainter {
  final Logger _logger = Logger(LogDistricts.DISTANCE_PAINTER);

  final double distance;
  final Offset viewCenter;

  final double _offsetPerDigit = 4.57;
  Offset _zeroPoint;
  final Offset _zeroPointWithoutTolerance = Offset(-29, 0);
  final Offset _zeroPointWithTolerance = Offset(-47, 0);

  Paragraph _paragraph;
  double _radians;
  Offset _position;

  DistancePainter({@material.required Offset start,
    @material.required Offset end,
    @material.required this.distance,
    @material.required this.viewCenter,
    @material.required double tolerance,
    @material.required UnitOfMeasurement unitOfMeasurement,
    @material.required DistanceStyle style}) {
    if (style.showTolerance) {
      _zeroPoint = _zeroPointWithTolerance;
    } else {
      _zeroPoint = _zeroPointWithoutTolerance;
    }

    if (distance > 0) {
      _zeroPoint -= Offset(((log(distance) / log(10)).floor() - 1) * _offsetPerDigit, 0);
    }

    Offset difference = end - start;
    _position = start + difference / 2.0;
    _radians = difference.direction;

    if (_radians.abs() >= pi / 2.0) {
      _radians += pi;
    }

    Offset positionToCenter = viewCenter - _position;

    Offset offset = difference.normal();
    offset *= offset
        .cosAlpha(positionToCenter)
        .sign;

    ParagraphBuilder paragraphBuilder = ParagraphBuilder(
      ParagraphStyle(
        textAlign: TextAlign.start,
        textDirection: TextDirection.ltr,
        maxLines: 1,
        height: 0.5,
        fontStyle: FontStyle.normal,
      ),
    );
    paragraphBuilder.pushStyle(TextStyle(color: style.textColor),);
    if (style.showTolerance) {
      paragraphBuilder.addText("${distance?.toStringAsFixed(style.numDecimalPlaces)}±${tolerance.toStringAsFixed(style.numDecimalPlaces)}mm");
    } else {
      paragraphBuilder.addText("${distance?.toStringAsFixed(style.numDecimalPlaces)}${unitOfMeasurement.getAbbreviation()}");
    }

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

    return thisNormalized.dx * otherNormalized.dx + thisNormalized.dy * otherNormalized.dy;
  }
}