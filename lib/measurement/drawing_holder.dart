import 'dart:ui';

class DrawingHolder {
  final List<Offset> points;
  final List<double> distances;

  DrawingHolder(this.points, this.distances);

  @override
  String toString() {
    return super.toString() + " points: $points, distances: $distances";
  }
}