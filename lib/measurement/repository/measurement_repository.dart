///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

import 'dart:math';
import 'dart:ui';

import 'package:measurements/measurement/drawing_holder.dart';
import 'package:measurements/measurements.dart';
import 'package:measurements/metadata/repository/metadata_repository.dart';
import 'package:measurements/util/logger.dart';
import 'package:measurements/util/utils.dart';
import 'package:rxdart/rxdart.dart';

enum TouchState {
  FREE,
  DOWN,
  MOVE,
  UP,
}

class MeasurementRepository {
  final _logger = Logger(LogDistricts.MEASUREMENT_REPOSITORY);

  final _points = BehaviorSubject<List<Offset>>.seeded(List());
  final _distances = BehaviorSubject<List<LengthUnit>>.seeded(List());
  final _drawingHolder = BehaviorSubject<DrawingHolder>();

  MeasurementController _controller;
  LengthUnit _transformationFactor;
  double _imageToDocumentScaleFactor = 1.0;

  int _currentIndex = -1;
  TouchState _currentState = TouchState.FREE;

  List<Offset> _absolutePoints = List();
  double _zoomLevel = 1.0;
  Offset _backgroundPosition = Offset(0, 0);
  Offset _viewCenterPosition = Offset(0, 0);

  MeasurementRepository(MetadataRepository repository) {
    repository.controller.listen((controller) => _controller = controller);
    repository.viewCenter.listen((viewCenter) => _viewCenterPosition = viewCenter);
    repository.imageToDocumentScaleFactor.listen((scaleFactor) {
      _imageToDocumentScaleFactor = scaleFactor;
      _logger.log("image to document factor: $_imageToDocumentScaleFactor");
      _updatePoints();
    });
    repository.transformationFactor.listen((factor) {
      if (_transformationFactor != factor) {
        _transformationFactor = factor;
        _movementFinished();
      }
    });
    repository.zoom.listen((zoom) {
      _zoomLevel = zoom;
      _publishPoints();
    });
    repository.backgroundPosition.listen((backgroundPosition) {
      _backgroundPosition = Offset(backgroundPosition.dx, -backgroundPosition.dy);
      _publishPoints();
    });
  }

  Stream<List<Offset>> get points => _points.stream;

  Stream<DrawingHolder> get drawingHolder => _drawingHolder.stream;

  void registerDownEvent(Offset position) {
    if (_currentState != TouchState.FREE) return;
    _currentState = TouchState.DOWN;

    Offset absoluteCenteredPosition = _convertIntoAbsolutePosition(position, _viewCenterPosition);

    int closestIndex = _getClosestPointIndex(absoluteCenteredPosition);

    if (closestIndex >= 0) {
      Offset closestPoint = _absolutePoints[closestIndex];

      if ((_convertIntoRelativePosition(closestPoint, _viewCenterPosition) - position).distance > 40.0) {
        _currentIndex = _addNewPoint(absoluteCenteredPosition);
      } else {
        _currentIndex = closestIndex;
        _updatePoint(absoluteCenteredPosition, _currentIndex);
      }
    } else {
      _currentIndex = _addNewPoint(absoluteCenteredPosition);
    }

    _movementStarted(_currentIndex);
  }

  void registerMoveEvent(Offset position) {
    if (_currentState != TouchState.DOWN && _currentState != TouchState.MOVE) return;
    _currentState = TouchState.MOVE;

    _updatePoint(_convertIntoAbsolutePosition(position, _viewCenterPosition), _currentIndex);
  }

  void registerUpEvent(Offset position) {
    if (_currentState != TouchState.DOWN && _currentState != TouchState.MOVE) return;
    _currentState = TouchState.UP;

    _updatePoint(_convertIntoAbsolutePosition(position, _viewCenterPosition), _currentIndex);
    _currentIndex = -1;
    _movementFinished();

    _currentState = TouchState.FREE;
  }

  void dispose() {
    _points.close();
    _distances.close();
    _drawingHolder.close();
  }

  Offset convertIntoAbsoluteTopLeftPosition(Offset position) {
    Offset absoluteCenterPosition = _convertIntoAbsolutePosition(position, _viewCenterPosition) / _imageToDocumentScaleFactor;

    return Offset(absoluteCenterPosition.dx + _viewCenterPosition.dx, _viewCenterPosition.dy - absoluteCenterPosition.dy);
  }

  Offset _convertIntoAbsolutePosition(Offset position, Offset viewCenter) {
    return (Offset(position.dx - viewCenter.dx, viewCenter.dy - position.dy) - _backgroundPosition) / _zoomLevel * _imageToDocumentScaleFactor;
  }

  Offset _convertIntoRelativePosition(Offset position, Offset viewCenter) {
    Offset scaledPosition = position / _imageToDocumentScaleFactor * _zoomLevel;

    return Offset(scaledPosition.dx + viewCenter.dx + _backgroundPosition.dx, viewCenter.dy - scaledPosition.dy - _backgroundPosition.dy);
  }

  List<Offset> _getRelativePoints() {
    return _absolutePoints.map((point) => _convertIntoRelativePosition(point, _viewCenterPosition)).toList();
  }

  void _publishPoints() {
    List<Offset> relativePoints = _getRelativePoints();

    _logger.log("relative points: $relativePoints");

    _points.add(relativePoints);
    _drawingHolder.add(DrawingHolder(relativePoints, _distances.value));
  }

  int _addNewPoint(Offset point) {
    _absolutePoints.add(point);
    _publishPoints();

    _logger.log("added point: $_absolutePoints");
    return _absolutePoints.length - 1;
  }

  void _updatePoint(Offset point, int index) {
    if (index >= 0) {
      _absolutePoints.setRange(index, index + 1, [point]);
      _publishPoints();

      _logger.log("updated point $index: $_absolutePoints");
    }
  }

  int _getClosestPointIndex(Offset reference) {
    int index = 0;

    List<_CompareHolder> sortedPoints = _absolutePoints
        .map((Offset point) => _CompareHolder(index++, (reference - point).distance))
        .toList();

    sortedPoints.sort((_CompareHolder a, _CompareHolder b) => a.distance.compareTo(b.distance));

    return sortedPoints.length > 0 ? sortedPoints[0].index : -1;
  }

  void _publishDistances(List<LengthUnit> distances) {
    _distances.add(distances);
    _drawingHolder.add(DrawingHolder(_getRelativePoints(), distances));
  }

  void _movementStarted(int index) {
    List<LengthUnit> distances = List()
      ..addAll(_distances.value);

    distances.setRange(max(0, index - 1), min(distances.length, index + 1), [null, null]);
    _publishDistances(distances);

    _logger.log("started moving point with index: $index");
  }

  void _movementFinished() {
    if (_transformationFactor != null && _absolutePoints.length >= 2) {
      List<LengthUnit> distances = List();
      _absolutePoints.doInBetween((start, end) => distances.add(_transformationFactor * (start - end).distance));
      _publishDistances(distances);

      _controller?.distances = distances.map((unit) => unit.value).toList();
    }
  }

  _updatePoints() {
    _logger.log("absolute position: $_absolutePoints new view center $_viewCenterPosition");
    _publishPoints();
  }
}

class _CompareHolder {
  double distance;
  int index;

  _CompareHolder(this.index, this.distance);
}