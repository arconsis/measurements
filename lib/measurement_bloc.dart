import 'dart:async';

import 'package:measurements/bloc/bloc_provider.dart';
import 'package:measurements/point.dart';

class MeasurementBloc extends BlocBase {

  static bool defaultPointSetState = false;
  bool measurementPointsSet = defaultPointSetState;
  final _measurementPointsSetController = StreamController<bool>();

  Stream<bool> get measurementPointsSetStream => _measurementPointsSetController.stream;

  void setMeasurementPointsSet(bool pointsSet) {
    _measurementPointsSetController.add(pointsSet);
  }


  double pixelDistance;
  final _pixelDistanceController = StreamController<double>();

  Stream<double> get pixelDistanceStream => _pixelDistanceController.stream;

  void setPixelDistance(double distance) {
    _pixelDistanceController.add(distance);
  }


  Point downPoint;
  final _downPointController = StreamController<Point>();

  Stream<Point> get downPointStream => _downPointController.stream;

  void setDownPoint(Point downPoint) {
    _downPointController.add(downPoint);
  }


  Point upPoint;
  final _upPointController = StreamController<Point>();

  Stream<Point> get upPointStream => _upPointController.stream;

  void setupPoint(Point upPoint) {
    _upPointController.add(upPoint);
  }


  @override
  void dispose() {
    _pixelDistanceController.close();
    _measurementPointsSetController.close();
    _downPointController.close();
    _upPointController.close();
  }
}