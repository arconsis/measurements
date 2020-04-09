import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:measurements/bloc/bloc_provider.dart';
import 'package:measurements/util/logger.dart';
import 'package:measurements/util/utils.dart';

class MeasurementBloc extends BlocBase {
  final Logger logger = Logger(LogDistricts.BLOC);

  final _pointsController = StreamController<List<Offset>>.broadcast();
  final _distanceController = StreamController<List<double>>.broadcast();

  final _orientationController = StreamController<Orientation>();
  final _viewWidthController = StreamController<double>();

  final _scaleController = StreamController<double>();
  final _zoomLevelController = StreamController<double>();
  final _showDistanceController = StreamController<bool>.broadcast();
  final _enableMeasurementController = StreamController<bool>.broadcast();

  Size _documentSize;
  Function(List<double>) _distanceCallback;
  double _scale;
  double _zoomLevel = 1.0;
  bool _showDistance;
  bool _enableMeasure;

  List<Offset> _points = List();
  List<double> _distances = List();

  bool _didUpdateOrientation = true;
  Orientation _orientation;
  Orientation _lastOrientation;
  double _viewWidth;
  double _lastViewWidth;

  double _transformationFactor;
  double _originalSizeZoomLevel;

  int addPoint(Offset point) {
    if (!_enableMeasure) return -1;

    _points.add(point);
    _pointsController.add(_points);

    logger.log("Added points: $_points");
    return _points.length - 1;
  }

  void updatePoint(Offset point, int index) {
    if (!_enableMeasure) return;

    _points.replaceRange(index, index + 1, {point});
    _pointsController.add(_points);

    logger.log("updated point $index: $_points");
  }

  int getClosestPointIndex(Offset reference) {
    if (!_enableMeasure) return -1;

    int index = 0;

    List<CompareHolder> sortedPoints = _points
        .map((Offset point) => CompareHolder(index++, (reference - point).distance))
        .toList();

    sortedPoints.sort((CompareHolder a, CompareHolder b) => a.distance.compareTo(b.distance));

    return sortedPoints.length > 0 ? sortedPoints[0].index : -1;
  }

  Offset getPoint(int index) => _points[index];

  Stream<List<Offset>> get pointsStream => _pointsController.stream;

  Stream<List<double>> get distancesStream => _distanceController.stream;

  Stream<bool> get showDistanceStream => _showDistanceController.stream;

  Stream<bool> get measureStream => _enableMeasurementController.stream;


  List<Offset> get points => _points;

  List<double> get distances => _distances;

  bool get showDistance => _showDistance;

  bool get measure => _enableMeasure;


  set orientation(Orientation orientation) => _orientation != orientation ? _orientationController.add(orientation) : null;

  set viewWidth(double width) => _viewWidth != width ? _viewWidthController.add(width) : null;

  set scale(double scale) => _scale != scale ? _scaleController.add(scale) : null;

  set zoomLevel(double zoomLevel) => _zoomLevel != zoomLevel ? _zoomLevelController.add(zoomLevel) : null;

  set showDistance(bool show) => _showDistance != show ? _showDistanceController.add(show) : null;

  set measuring(bool measure) => _enableMeasure != measure ? _enableMeasurementController.add(measure) : null;


  MeasurementBloc(this._documentSize, this._distanceCallback) {
    logger.log("Creating Bloc");

    pointsStream.listen((List<Offset> points) {
      _points = points;
      logger.log("points: $_points");

      _updateDistances();
    });

    distancesStream.listen((List<double> distances) {
      _distances = distances;
      if (_distanceCallback != null) _distanceCallback(distances);
    });

    _orientationController.stream.listen((Orientation orientation) {
      if (_orientation != orientation) {
        _lastOrientation = _orientation;
        _didUpdateOrientation = false;

        _orientation = orientation;

        _updatePointsToOrientation();
      }
    });

    _viewWidthController.stream.listen((double viewWidth) {
      if (viewWidth != _viewWidth) {
        _lastViewWidth = _viewWidth;
        _didUpdateOrientation = false;

        _viewWidth = viewWidth;
        logger.log("viewWidth: $_viewWidth");

        _updateTransformationFactor();
        _updatePointsToOrientation();
      }
    });

    _scaleController.stream.listen((double scale) {
      _scale = scale;
      logger.log("scale: $scale");

      _updateTransformationFactor();
    });

    _zoomLevelController.stream.listen((double zoomLevel) {
      _zoomLevel = zoomLevel;
      logger.log("zoomLevel: $zoomLevel");

      _updateTransformationFactor();
    });

    showDistanceStream.listen((bool show) {
      _showDistance = show;
      logger.log("showDistance: $_showDistance");
    });

    measureStream.listen((bool measure) {
      _enableMeasure = measure;
      logger.log("enableMeasure: $_enableMeasure");
    });
  }

  void _updateDistances() {
    if (_transformationFactor != null && _transformationFactor != 0.0 && _points.length >= 2) {
      List<double> distances = List();

      _points.doInBetween((start, end) => distances.add((start - end).distance * _transformationFactor));

      _distanceController.add(distances);
    }
  }

  void _updateTransformationFactor() {
    if (_scale != null && _zoomLevel != null && _viewWidth != null) {
      _transformationFactor = _documentSize.width / (_scale * _viewWidth * _zoomLevel);
    }
  }

  void _updatePointsToOrientation() {
    if (!_didUpdateOrientation && _lastOrientation != null && _lastViewWidth != null) {
      double scale = _viewWidth / _lastViewWidth;

      List<Offset> scaledPoints = _points.map((Offset point) => point * scale).toList();

      _pointsController.add(scaledPoints);

      _didUpdateOrientation = true;
      _lastOrientation = null;
      _lastViewWidth = null;

      logger.log("updated points to orientation");
    }
  }

  @override
  void dispose() {
    logger.log("Disposing Bloc");

    _pointsController?.close();
    _distanceController?.close();

    _orientationController?.close();
    _viewWidthController?.close();

    _scaleController?.close();
    _zoomLevelController?.close();
    _showDistanceController?.close();
    _enableMeasurementController?.close();
  }
}

class CompareHolder {
  double distance;
  int index;

  CompareHolder(this.index, this.distance);
}