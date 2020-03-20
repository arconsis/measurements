import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:measurements/bloc/bloc_provider.dart';
import 'package:measurements/overlay/point.dart';
import 'package:measurements/util/Logger.dart';

class MeasurementBloc extends BlocBase {

  final MethodChannel _deviceInfoChannel = MethodChannel("measurements");

  final _fromPointController = StreamController<Point>();
  final _toPointController = StreamController<Point>();
  final _viewWidthController = StreamController<double>();

  final _scaleController = StreamController<double>();
  final _zoomLevelController = StreamController<double>();


  Size _documentSize;
  Sink<double> _outputSink;
  double _scale;
  double _zoomLevel = 1.0;

  Point _fromPoint;
  Point _toPoint;
  double _viewWidth;

  double _transformationFactor;
  double _originalSizeZoomLevel;

  set fromPoint(Point point) => _fromPointController.add(point);

  set toPoint(Point point) => _toPointController.add(point);

  set viewWidth(double width) => _viewWidthController.add(width);

  set scale(double scale) => _scaleController.add(scale);

  set zoomLevel(double zoomLevel) => _zoomLevelController.add(zoomLevel);

  MeasurementBloc(this._documentSize, this._outputSink) {
    _fromPointController.stream.listen((Point fromPoint) {
      _fromPoint = fromPoint;
      Logger.log("fromPoint: $_fromPoint", LogDistricts.BLOC);

      _updateDistance();
    });

    _toPointController.stream.listen((Point toPoint) {
      _toPoint = toPoint;
      Logger.log("toPoint: $toPoint", LogDistricts.BLOC);

      _updateDistance();
    });

    _scaleController.stream.listen((double scale) {
      _scale = scale;
      Logger.log("scale: $scale", LogDistricts.BLOC);

      _updateTransformationFactor();
    });

    _viewWidthController.stream.listen((double viewWidth) {
      _viewWidth = viewWidth;
      Logger.log("viewWidth: $viewWidth", LogDistricts.BLOC);

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
      double distance = (_fromPoint - _toPoint)?.length();

      _outputSink?.add(distance * _transformationFactor);
    }
  }

  void _updateTransformationFactor() {
    if (_zoomLevel != null && _viewWidth != null) {
      _transformationFactor = _documentSize.width / (_scale * _viewWidth * _zoomLevel);
    }
  }

  Future<double> zoomToOriginal() async {
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
    _scaleController?.close();
    _viewWidthController?.close();
    _zoomLevelController?.close();
  }
}