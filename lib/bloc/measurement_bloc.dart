import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:measurements/bloc/bloc_provider.dart';
import 'package:measurements/overlay/point.dart';

const double _mmPerInch = 25.4;

class MeasurementBloc extends BlocBase {

  final double _scale;
  final Size _documentSize;
  final Sink<double> _outputSink;

  final MethodChannel _deviceInfoChannel = MethodChannel("measurements");

  Point _fromPoint;
  Point _toPoint;
  double _zoomLevel = 1.0;
  double _viewWidth;
  double _transformationFactor;
  double _originalSizeZoomLevel;

  final _fromPointController = StreamController<Point>();
  final _toPointController = StreamController<Point>();
  final _zoomLevelController = StreamController<double>();
  final _viewWidthController = StreamController<double>();

  MeasurementBloc(this._scale, this._documentSize, this._outputSink) {
    _fromPointController.stream.listen((Point fromPoint) {
      _fromPoint = fromPoint;

      _updateDistance();
    });

    _toPointController.stream.listen((Point toPoint) {
      _toPoint = toPoint;

      _updateDistance();
    });

    _viewWidthController.stream.listen((double viewWidth) {
      _viewWidth = viewWidth;

      _updateTransformationFactor();
    });

    _zoomLevelController.stream.listen((double zoomLevel) {
      _zoomLevel = zoomLevel;

      _updateTransformationFactor();
    });
  }

  void _updateDistance() {
    if (_transformationFactor != null && _transformationFactor != 0.0) {
      double distance = (_fromPoint - _toPoint)?.length();

      _outputSink?.add(distance * _transformationFactor);
    }
  }

  void _updateTransformationFactor() {
    if (_zoomLevel != null && _viewWidth != null) {
      _transformationFactor = _documentSize.width / (_scale * _viewWidth * _zoomLevel);
    }
  }

  Sink<Point> get fromPoint => _fromPointController.sink;

  Sink<Point> get toPoint => _toPointController.sink;

  Sink<double> get viewWidth => _viewWidthController.sink;

  Sink<double> get zoomLevel => _zoomLevelController.sink;

  Future<double> zoomToOriginal() async {
    if (_originalSizeZoomLevel == null) {
      Map size = await _deviceInfoChannel.invokeMethod("getPhysicalScreenSize");

      double screenWidth = size["width"] * _mmPerInch;

      _originalSizeZoomLevel = _documentSize.width / (screenWidth * _scale);
    }

    return _originalSizeZoomLevel;
  }

  @override
  void dispose() {
    _fromPointController?.close();
    _toPointController?.close();
    _viewWidthController?.close();
    _zoomLevelController?.close();
  }
}