import 'dart:ui';

import 'package:equatable/equatable.dart';

class Holder extends Equatable {
  final Offset start, end;
  double distance;

  Holder(this.start, this.end);

  Holder.withDistance(this.start, this.end, this.distance);

  @override
  String toString() {
    return super.toString() + " First Point: $start - Second Point: $end - Distance: $distance";
  }

  @override
  List<Object> get props => [start, end, distance];
}