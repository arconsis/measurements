import 'dart:ui';

class Holder {
  Offset start, end;
  double distance;

  Holder(this.start, this.end);

  @override
  String toString() {
    return "First Point: $start - Second Point: $end - Distance: $distance";
  }
}