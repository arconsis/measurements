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


  double logicalPdfViewWidth;
  final _logicalPdfViewWidthController = StreamController<double>();

  Stream<double> get logicalPdfViewWidthStream => _logicalPdfViewWidthController.stream;

  void setLogicalPdfViewWidth(double width) {
    _logicalPdfViewWidthController.add(width);
  }


  double zoomTo;
  final _zoomToController = StreamController<double>();

  Stream<double> get zoomToStream => _zoomToController.stream;

  void setZoomTo(double zoomTo) {
    _zoomToController.add(zoomTo);
  }


  @override
  void dispose() {
    _pixelDistanceController.close();
    _zoomLevelController.close();
    _zoomToController.close();
  }
}