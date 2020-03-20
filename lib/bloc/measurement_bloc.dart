import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:measurements/bloc/bloc_provider.dart';
import 'package:measurements/util/Logger.dart';

class MeasurementBloc extends BlocBase {

  final MethodChannel _deviceInfoChannel = MethodChannel("measurements");

  final _fromPointController = StreamController<Offset>();
  final _toPointController = StreamController<Offset>();
  final _pointsController = StreamController<Set<Offset>>();
  final _distanceController = StreamController<double>.broadcast();

  final _orientationController = StreamController<Orientation>();
  final _viewWidthController = StreamController<double>();

  final _scaleController = StreamController<double>();
  final _zoomLevelController = StreamController<double>();


  Size _documentSize;
  Sink<double> _outputSink;
  double _scale;
  double _zoomLevel = 1.0;

  Offset _fromPoint;
  Offset _toPoint;

  bool _didUpdateOrientation = true;
  Orientation _orientation;
  Orientation _lastOrientation;
  double _viewWidth;
  double _lastViewWidth;

  double _transformationFactor;
  double _originalSizeZoomLevel;

  set fromPoint(Offset point) => _fromPointController.add(point);

  set toPoint(Offset point) => _toPointController.add(point);

  Stream<Set<Offset>> get pointStream => _pointsController.stream;

  Stream<double> get distanceStream => _distanceController.stream;

  set orientation(Orientation orientation) => _orientationController.add(orientation);

  set viewWidth(double width) => _viewWidthController.add(width);

  set scale(double scale) => _scaleController.add(scale);

  set zoomLevel(double zoomLevel) => _zoomLevelController.add(zoomLevel);

  MeasurementBloc(this._documentSize, this._outputSink) {
    _fromPointController.stream.listen((Offset fromPoint) {
      _fromPoint = fromPoint;
      Logger.log("fromPoint: $_fromPoint", LogDistricts.BLOC);

      _updateDistance();

      _pointsController.add({_fromPoint, _toPoint});
    });

    _toPointController.stream.listen((Offset toPoint) {
      _toPoint = toPoint;
      Logger.log("toPoint: $toPoint", LogDistricts.BLOC);

      _updateDistance();

      _pointsController.add({_fromPoint, _toPoint});
    });

    _distanceController.stream.listen((double distance) {
      _outputSink.add(distance);
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
        Logger.log("viewWidth: $_viewWidth", LogDistricts.BLOC);

        _updateTransformationFactor();
        _updatePointsToOrientation();
      }
    });

    _scaleController.stream.listen((double scale) {
      _scale = scale;
      Logger.log("scale: $scale", LogDistricts.BLOC);

      _updateTransformationFactor();
    });

    _zoomLevelController.stream.listen((double zoomLevel) {
      _zoomLevel = zoomLevel;
      Logger.log("zoomLevel: $zoomLevel", LogDistricts.BLOC);

      _updateTransformationFactor();
    });
  }

  void _updateDistance() {
    if (_transformationFactor != null && _transformationFactor != 0.0 && _fromPoint != null && _toPoint != null) {
      double distance = (_fromPoint - _toPoint)?.distance;

      _distanceController.add(distance * _transformationFactor);
    }
  }

  void _updateTransformationFactor() {
    if (_scale != null && _zoomLevel != null && _viewWidth != null) {
      _transformationFactor = _documentSize.width / (_scale * _viewWidth * _zoomLevel);
    }
  }

  void _updatePointsToOrientation() {
    if (!_didUpdateOrientation && _lastOrientation != null && _lastViewWidth != null) {
      Offset fromPoint = _fromPoint;
      Offset toPoint = _toPoint;

      double scale = _viewWidth / _lastViewWidth;

      _fromPointController.add(fromPoint * scale);
      _toPointController.add(toPoint * scale);

      _didUpdateOrientation = true;
      _lastOrientation = null;
      _lastViewWidth = null;

      Logger.log("updated points to orientation", LogDistricts.BLOC);
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
    _fromPointController?.close();
    _toPointController?.close();
    _pointsController?.close();
    _distanceController?.close();

    _orientationController?.close();
    _viewWidthController?.close();

    _scaleController?.close();
    _zoomLevelController?.close();
  }
}