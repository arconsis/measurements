/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'dart:ui';

import 'package:document_measure/src/util/colors.dart';
import 'package:equatable/equatable.dart';

abstract class LineType extends Equatable {
  final Color lineColor;

  const LineType(this.lineColor);
}

class SolidLine extends LineType {
  final double lineWidth;

  const SolidLine({this.lineWidth = 2, Color lineColor = drawColor}) : super(lineColor);

  @override
  List<Object> get props => [lineWidth, lineColor];
}

/// [LineType] to render a dashed line, like - - - -
///
/// [dashLength] is the length of one dash 1: - - 2: -- --
///
/// [dashDistance] is distance between two dashes 1: - - 2: -  -
class DashedLine extends LineType {
  final double dashWidth;
  final double dashLength;
  final double dashDistance;

  DashedLine({this.dashWidth = 2, this.dashLength = 5, this.dashDistance = 5, Color lineColor = drawColor}) : super(lineColor);

  @override
  List<Object> get props => [dashWidth, dashLength, dashDistance, lineColor];
}

/// Style class to customize the appearance of the placed points and lines between them.
///
/// The lines can by styles in their respective constructors ([SolidLine], [DashedLine]).
class PointStyle extends Equatable {
  final Color dotColor;
  final double dotRadius;

  final LineType lineType;

  const PointStyle({this.dotColor = drawColor, this.dotRadius = 4, this.lineType = const SolidLine()});

  @override
  List<Object> get props => [dotColor, dotRadius, lineType];
}
