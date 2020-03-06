import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:measurements/bloc/bloc_provider.dart';
import 'package:measurements/point.dart';

const double mmPerInch = 25.4;

class MeasurementBloc extends BlocBase {

  final double _scale;
  final Size _documentSize;
  final Sink<double> _outputSink;

  final MethodChannel _deviceInfoChannel = MethodChannel("measurements");
  MethodChannel _setZoomChannel;
  EventChannel _getZoomChannel;

  Point _fromPoint;
  Point _toPoint;
  double _zoomLevel = 1.0;
  double _viewWidth;
  double _transformationFactor;
  double _originalSizeZoomLevel;

  final _fromPointController = StreamController<Point>();
  final _toPointController = StreamController<Point>();
  final _viewWidthController = StreamController<double>();
  final _viewIdController = StreamController<int>();

  MeasurementBloc(this._scale, this._documentSize, this._outputSink) {
    _fromPointController.stream.listen((Point fromPoint) {
      _fromPoint = fromPoint;
      _toPoint = null;
    });

    _toPointController.stream.listen((Point toPoint) {
      _toPoint = toPoint;

      _updateDistance();
    });

    _viewWidthController.stream.listen((double viewWidth) {
      _viewWidth = viewWidth;

      _updateTransformationFactor();
    });

    _viewIdController.stream.listen((int id) {
      _setZoomChannel = MethodChannel("measurement_pdf_set_zoom_$id");
      _getZoomChannel = EventChannel("measurement_pdf_zoom_$id");

      _getZoomChannel.receiveBroadcastStream().listen((dynamic zoomLevel) {
        _zoomLevel = zoomLevel;

        _updateTransformationFactor();
      });
    });
  }

  void _updateDistance() {
    if (_transformationFactor != null && _transformationFactor != 0.0) {
      double distance = (_fromPoint - _toPoint).length();

      _outputSink.add(distance * _transformationFactor);
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

  Sink<int> get viewId => _viewIdController.sink;

  void zoomToOriginal() async {
    if (_originalSizeZoomLevel == null) {
      Map size = await _deviceInfoChannel.invokeMethod("getPhysicalScreenSize");

      double screenWidth = size["width"] * mmPerInch;

      _originalSizeZoomLevel = _documentSize.width / (screenWidth * _scale);
    }

    _setZoomChannel.invokeMethod("setZoom", _originalSizeZoomLevel);
  }

  @override
  void dispose() {
    _fromPointController.close();
    _toPointController.close();
    _viewWidthController.close();
    _viewIdController.close();
  }
}