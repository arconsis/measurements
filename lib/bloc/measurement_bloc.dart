import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:measurements/bloc/bloc_provider.dart';
import 'package:measurements/util/logger.dart';
import 'package:measurements/util/utils.dart';

class MeasurementBloc extends BlocBase {
  final Logger logger = Logger(LogDistricts.BLOC);

  final MethodChannel _deviceInfoChannel = MethodChannel("measurements");

  final _pointsController = StreamController<List<Offset>>.broadcast();
  final _distanceController = StreamController<List<double>>.broadcast();

  final _showDistanceController = StreamController<bool>.broadcast();
  final _backgroundImageController = StreamController<ui.Image>.broadcast();

  Size _documentSize;
  Sink<List<double>> _outputSink;
  double _scale;
  double _zoomLevel = 1.0;
  bool _showDistance;
  bool _enableMeasure;
  ui.Image _currentBackgroundImage;

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

    _points.setRange(index, index + 1, [point]);
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

  void movementStarted(int index) {
    _distances.setRange(max(0, index - 1), min(_distances.length, index + 1), [null, null]);
    _distanceController.add(_distances);

    logger.log("started moving points with index: $index");
  }

  void movementFinished() {
    if (_transformationFactor != null && _transformationFactor != 0.0 && _points.length >= 2) {
      List<double> distances = List();

      _points.doInBetween((start, end) => distances.add((start - end).distance * _transformationFactor));

      _distanceController.add(distances);
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

  Offset getPoint(int index) => _points[index];

  Stream<List<Offset>> get pointsStream => _pointsController.stream;

  Stream<List<double>> get distancesStream => _distanceController.stream;

  Stream<bool> get showDistanceStream => _showDistanceController.stream;

  Stream<ui.Image> get backgroundStream => _backgroundImageController.stream;

  List<Offset> get points => _points;


  List<double> get distances => _distances;

  bool get showDistance => _showDistance;

  ui.Image get backgroundImage => _currentBackgroundImage;

  set orientation(Orientation orientation) {
    if (_orientation != orientation) {
      _lastOrientation = _orientation;
      _didUpdateOrientation = false;

      _orientation = orientation;
      logger.log("oriantation: $orientation");

      _updatePointsToOrientation();
    }
  }

  set viewWidth(double width) {
    if (width != _viewWidth) {
      _lastViewWidth = _viewWidth;
      _didUpdateOrientation = false;

      _viewWidth = width;
      logger.log("viewWidth: $_viewWidth");

      _updateTransformationFactor();
      _updatePointsToOrientation();
    }
  }

  set scale(double scale) {
    if (_scale != scale) {
      _scale = scale;
      logger.log("scale: $_scale");

      _updateTransformationFactor();
    }
  }

  set zoomLevel(double zoomLevel) {
    _zoomLevel = zoomLevel;
    logger.log("zoomLevel: $zoomLevel");

    _updateTransformationFactor();
  }


  set measuring(bool measure) {
    if (_enableMeasure != measure) {
      _enableMeasure = measure;
      logger.log("enableMeasure: $_enableMeasure");
    }
  }

  set showDistance(bool show) => _showDistance != show ? _showDistanceController.add(show) : null;

  set backgroundImage(ui.Image image) => _currentBackgroundImage != image ? _backgroundImageController.add(image) : null;

  MeasurementBloc(this._documentSize, this._outputSink) {
    logger.log("Creating Bloc");

    pointsStream.listen((List<Offset> points) {
      _points = points;
      logger.log("points: $_points");
    });

    distancesStream.listen((List<double> distances) async {
      _distances = distances;
      logger.log("distances: $_distances");

      measure(logger, "adding to output sink took: ", () {
        _outputSink?.add(distances);
      });
    });

    showDistanceStream.listen((bool show) {
      _showDistance = show;
      logger.log("showDistance: $_showDistance");
    });

    _backgroundImageController.stream.listen((ui.Image currentImage) {
      logger.log("background image size: ${Size(currentImage.width.toDouble(), currentImage.height.toDouble())}");
      _currentBackgroundImage = currentImage;
    });
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
    _pointsController?.close();
    _distanceController?.close();

    _showDistanceController?.close();
    _backgroundImageController?.close();

    logger.log("disposed");
  }
}

class CompareHolder {
  double distance;
  int index;

  CompareHolder(this.index, this.distance);
}