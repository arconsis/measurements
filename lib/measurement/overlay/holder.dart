///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:measurements/measurements.dart';

class Holder extends Equatable {
  final Offset start, end;
  LengthUnit distance;

  Holder(this.start, this.end);

  Holder.withDistance(this.start, this.end, this.distance);

  @override
  String toString() {
    return super.toString() + " First Point: $start, Second Point: $end, Distance: $distance";
  }

  @override
  List<Object> get props => [start, end, distance];
}