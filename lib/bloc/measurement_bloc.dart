import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:measurements/bloc/bloc_provider.dart';
import 'package:measurements/util/logger.dart';
import 'package:measurements/util/utils.dart';

class MeasurementBloc extends BlocBase {
  final Logger logger = Logger(LogDistricts.BLOC);

  final MethodChannel _deviceInfoChannel = MethodChannel("measurements");

  final _pointsController = StreamController<List<Offset>>.broadcast();
  final _distanceController = StreamController<List<double>>.broadcast();

  final _orientationController = StreamController<Orientation>();
  final _viewWidthController = StreamController<double>();

  final _scaleController = StreamController<double>();
  final _zoomLevelController = StreamController<double>();


  Size _documentSize;
  Sink<List<double>> _outputSink;
  double _scale;
  double _zoomLevel = 1.0;

  List<Offset> _points = List();

  bool _didUpdateOrientation = true;
  Orientation _orientation;
  Orientation _lastOrientation;
  double _viewWidth;
  double _lastViewWidth;

  double _transformationFactor;
  double _originalSizeZoomLevel;

  int addPoint(Offset point) {
    _points.add(point);
    _pointsController.add(_points);

    logger.log("points: $_points");
    return _points.length - 1;
  }

  void updatePoint(Offset point, int index) {
    _points.replaceRange(index, index + 1, {point});
    _pointsController.add(_points);
  }

  Stream<List<Offset>> get pointsStream => _pointsController.stream;

  Stream<List<double>> get distancesStream => _distanceController.stream;

  set orientation(Orientation orientation) => _orientationController.add(orientation);

  set viewWidth(double width) => _viewWidthController.add(width);

  set scale(double scale) => _scaleController.add(scale);

  set zoomLevel(double zoomLevel) => _zoomLevelController.add(zoomLevel);

  MeasurementBloc(this._documentSize, this._outputSink) {
    _pointsController.stream.listen((List<Offset> points) {
      _points = points;
      logger.log("points: $_points");

      _updateDistances();
    });

    _distanceController.stream.listen((List<double> distances) {
      _outputSink.add(distances);
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

      List<Offset> scaledPoints = _points.map((Offset point) => point * scale).toList(growable: false);

      _pointsController.add(scaledPoints);

      _didUpdateOrientation = true;
      _lastOrientation = null;
      _lastViewWidth = null;

      logger.log("updated points to orientation");
    }
  }

  Future<double> getZoomFactorForOriginalSize() async {
    if (_originalSizeZoomLevel == null) {
      double dpm = await _deviceInfoChannel.invokeMethod("getPhysicalPixelsPerMM");

      double screenWidth = _viewWidth / dpm;

      _originalSizeZoomLevel = _documentSize.width / (screenWidth * _scale);
    }

    return _originalSizeZoomLevel;
  }

  @override
  void dispose() {
    _pointsController?.close();
    _distanceController?.close();

    _orientationController?.close();
    _viewWidthController?.close();

    _scaleController?.close();
    _zoomLevelController?.close();
  }
}