/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'dart:math';
import 'dart:ui';

import 'package:document_measure/document_measure.dart';
import 'package:flutter/material.dart' as material;

class DistancePainter extends material.CustomPainter {
  static final double _log10 = log(10);
  static final double _offsetPerDigit = 4.57;

  final LengthUnit distance;
  final Offset viewCenter;

  Offset _zeroPoint;
  final Offset _zeroPointWithoutTolerance = Offset(-29, 0);
  final Offset _zeroPointWithTolerance = Offset(-47, 0);

  Paragraph _paragraph;
  double _radians;
  Offset _position;

  ParagraphBuilder paragraphBuilder = ParagraphBuilder(
    ParagraphStyle(
      textAlign: TextAlign.start,
      textDirection: TextDirection.ltr,
      maxLines: 1,
      height: 0.5,
      fontStyle: FontStyle.normal,
    ),
  );

  DistancePainter(
      {@material.required Offset start,
      @material.required Offset end,
      @material.required this.distance,
      @material.required this.viewCenter,
      @material.required double tolerance,
      @material.required DistanceStyle style}) {
    if (style.showTolerance) {
      _zeroPoint = _zeroPointWithTolerance;
    } else {
      _zeroPoint = _zeroPointWithoutTolerance;
    }

    var distanceValue = distance.value;

    if (distanceValue > 0) {
      _zeroPoint -= Offset(
          ((log(distanceValue) / _log10).floor() - 1) * _offsetPerDigit, 0);
    }

    var difference = end - start;
    _position = start + difference / 2.0;
    _radians = difference.direction;

    if (_radians.abs() >= pi / 2.0) {
      _radians += pi;
    }

    var positionToCenter = viewCenter - _position;

    var offset = difference.normal();
    offset *= offset.cosAlpha(positionToCenter).sign;

    paragraphBuilder.pushStyle(TextStyle(color: style.textColor));
    if (style.showTolerance) {
      paragraphBuilder.addText(
          '${distanceValue?.toStringAsFixed(style.numDecimalPlaces)}±${tolerance.toStringAsFixed(style.numDecimalPlaces)}${distance.getAbbreviation()}');
    } else {
      paragraphBuilder.addText(
          '${distanceValue?.toStringAsFixed(style.numDecimalPlaces)}${distance.getAbbreviation()}');
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
    var old = oldDelegate as DistancePainter;

    return distance != old.distance || _position != old._position;
  }
}

extension OffsetExtension on Offset {
  Offset normal() {
    var normalized = normalize();
    return Offset(-normalized.dy, normalized.dx);
  }

  Offset normalize() {
    return this / distance;
  }

  double cosAlpha(Offset other) {
    var thisNormalized = normalize();
    var otherNormalized = other.normalize();

    return thisNormalized.dx * otherNormalized.dx +
        thisNormalized.dy * otherNormalized.dy;
  }
}
