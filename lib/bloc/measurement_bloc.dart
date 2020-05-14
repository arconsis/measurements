import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart'; // 1432: importing from darts widget library should be avoided in bloc

import 'package:measurements/bloc/bloc_provider.dart';
import 'package:measurements/util/logger.dart';
import 'package:measurements/util/utils.dart';
import 'package:rxdart/rxdart.dart';

class MeasurementBloc extends BlocBase {
  final Logger logger = Logger(LogDistricts.BLOC);

//  final _pointsController = StreamController<List<Offset>>.broadcast();
  final _pointsController = //1432: example with behaviour subject. it woul be better to not use behaviour subject, but use a repository holding the List with points
      BehaviorSubject<List<Offset>>.seeded(List<Offset>.of([]));
// 1432: some controllers can be combined using a custom model representing all of these values (less rebuilding)

  final _distanceController = StreamController<List<double>>.broadcast();

  final _orientationController = StreamController<Orientation>();
  final _viewWidthController = StreamController<double>();

  final _scaleController = StreamController<double>();
  final _zoomLevelController = StreamController<double>();
  final _showDistanceController = StreamController<bool>.broadcast();
  final _enableMeasurementController = StreamController<bool>.broadcast();

  // 1432: it is not good practice to have so man class variables inside bloc. class variables are best inside repository.
  Size _documentSize;
  Function(List<double>, double) _distanceCallback;
  double _scale;
  double _zoomLevel = 1.0;
  bool _showDistance;
  bool _enableMeasure;

  // List<Offset> _points = List();
  List<double> _distances = List();

  bool _didUpdateOrientation = true;
  Orientation _orientation;
  Orientation _lastOrientation;
  double _viewWidth;
  double _lastViewWidth;

  double _transformationFactor;
  double _originalSizeZoomLevel;

// 1432: getters and setters need to be on top
  Offset getPoint(int index) => _pointsController.value[index];

  Stream<List<Offset>> get pointsStream => _pointsController.stream;

  Stream<List<double>> get distancesStream => _distanceController.stream;

  Stream<bool> get showDistanceStream => _showDistanceController.stream;

  Stream<bool> get measureStream => _enableMeasurementController.stream;

  // List<Offset> get points => _points;

  List<double> get distances => _distances;

  bool get showDistance =>
      _showDistance; // 1432: blocs may only expose streams and methods

  bool get measure => _enableMeasure;

  set orientation(Orientation orientation) => _orientation != orientation
      ? _orientationController.add(orientation)
      : null;

  set viewWidth(double width) =>
      _viewWidth != width ? _viewWidthController.add(width) : null;

  set scale(double scale) =>
      _scale != scale ? _scaleController.add(scale) : null;

  set zoomLevel(double zoomLevel) =>
      _zoomLevel != zoomLevel ? _zoomLevelController.add(zoomLevel) : null;

  set showDistance(bool show) =>
      _showDistance != show ? _showDistanceController.add(show) : null;

  set measuring(bool measure) => _enableMeasure != measure
      ? _enableMeasurementController.add(measure)
      : null;

// 1432: constructor needs to be on top too
  MeasurementBloc(this._documentSize, this._distanceCallback) {
    //1432: this method is too huge
    logger.log("Creating Bloc");

/*    pointsStream.listen((List<Offset> points) { // 1432: do not listen inside of bloc to its own streams. only UI listens to bloc
      _points = points;
      logger.log("points: $_points");

      _updateDistances();
    });*/

    distancesStream.listen((List<double> distances) {
      //1432: do only listen from external repositories. why are you listening here?
      _distances = distances;
      if (_distanceCallback != null)
        _distanceCallback(distances, sumAllDistances(distances));
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

  int addPoint(Offset point) {
    if (!_enableMeasure) return -1;

//    _points.add(point);
    _pointsController
        .add([..._pointsController.value, point]); //1432: adding new points List
    _updateDistances();
    logger.log("Added points: ${_pointsController.value}");
    return _pointsController.value.length -
        1; //1432: illegal. only private functions may return values inside bloc (for other calling functions)
  }

  void updatePoint(Offset point, int index) {
    if (!_enableMeasure) return;

    List<Offset> points = [..._pointsController.value, point]
      ..replaceRange(index, index + 1, {point});
    _pointsController.add(points);
    _updateDistances();
    logger.log("updated point $index: $points");
  }

  int getClosestPointIndex(Offset reference) {
    if (!_enableMeasure) return -1;

    int index = 0;

    List<CompareHolder> sortedPoints = _pointsController.value
        .map((Offset point) =>
            CompareHolder(index++, (reference - point).distance))
        .toList();

    sortedPoints.sort(
        (CompareHolder a, CompareHolder b) => a.distance.compareTo(b.distance));

    return sortedPoints.length > 0 ? sortedPoints[0].index : -1;
  }

  double sumAllDistances(List<double> distances) {
    double overallDistance = 0;
    distances.forEach((singleDistance) => overallDistance += singleDistance);
    return overallDistance;
  }

  void _updateDistances() {
    if (_transformationFactor != null &&
        _transformationFactor != 0.0 &&
        _pointsController.value.length >= 2) {
      List<double> distances = List();

      _pointsController.value.doInBetween((start, end) =>
          distances.add((start - end).distance * _transformationFactor));

      _distanceController.add(distances);
    }
  }

  void _updateTransformationFactor() {
    if (_scale != null && _zoomLevel != null && _viewWidth != null) {
      _transformationFactor =
          _documentSize.width / (_scale * _viewWidth * _zoomLevel);
    }
  }

  void _updatePointsToOrientation() {
    if (!_didUpdateOrientation &&
        _lastOrientation != null &&
        _lastViewWidth != null) {
      double scale = _viewWidth / _lastViewWidth;

      List<Offset> scaledPoints =
          _pointsController.value.map((Offset point) => point * scale).toList();

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
