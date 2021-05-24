/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'dart:ui';

import 'package:document_measure/document_measure.dart';
import 'package:equatable/equatable.dart';

class Holder extends Equatable {
  final Offset start, end;
  final LengthUnit? distance;

  Holder(this.start, this.end, {this.distance = const Millimeter(0)});

  Holder.extend(Holder old, LengthUnit? distance)
      : this(old.start, old.end, distance: distance);

  Holder.withDistance(this.start, this.end, this.distance);

  @override
  String toString() {
    return super.toString() +
        ' First Point: $start, Second Point: $end, Distance: $distance';
  }

  @override
  List<Object?> get props => [start, end, distance];
}
