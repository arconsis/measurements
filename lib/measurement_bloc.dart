import 'dart:async';

import 'package:measurements/bloc/bloc_provider.dart';

class MeasurementBloc extends BlocBase {

  double pixelDistance;
  final _pixelDistanceController = StreamController<double>();

  Stream<double> get pixelDistanceStream => _pixelDistanceController.stream;

  void setPixelDistance(double distance) {
    _pixelDistanceController.add(distance);
  }


  double zoomLevel;
  final _zoomLevelController = StreamController<double>();

  Stream<double> get zoomLevelStream => _zoomLevelController.stream;

  void setZoomLevel(double zoomLevel) {
    _zoomLevelController.add(zoomLevel);
  }


  @override
  void dispose() {
    _pixelDistanceController.close();
  }
}