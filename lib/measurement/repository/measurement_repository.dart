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

  Function(List<double>) _callback;
  LengthUnit _transformationFactor;

  int _currentIndex = -1;
  TouchState _currentState = TouchState.FREE;

  List<Offset> _absolutePoints = List();
  double _zoomLevel = 1.0;
  Offset _backgroundPosition = Offset(0, 0);

  MeasurementRepository(MetadataRepository repository) {
    repository.viewScaleFactor.listen((factor) => _updatePoints(factor));
    repository.callback.listen((callback) => _callback = callback);
    repository.transformationFactor.listen((factor) {
      if (_transformationFactor != factor) {
        _transformationFactor = factor;
        _movementFinished();
      } else {
        _transformationFactor = factor;
      }
    });
    repository.zoom.listen((zoom) {
      _zoomLevel = zoom;
      _publishPoints();
    });
    repository.backgroundPosition.listen((backgroundPosition) {
      _backgroundPosition = backgroundPosition;
      _publishPoints();
    });

    _logger.log("Created Repository");
  }

  Stream<List<Offset>> get points => _points.stream;

  Stream<DrawingHolder> get drawingHolder => _drawingHolder.stream;

  void registerDownEvent(Offset position) {
    if (_currentState != TouchState.FREE) return;
    _currentState = TouchState.DOWN;

    Offset absolutePosition = _convertIntoAbsolutePosition(position);

    int closestIndex = _getClosestPointIndex(absolutePosition);

    if (closestIndex >= 0) {
      Offset closestPoint = _absolutePoints[closestIndex];

      if ((_convertIntoRelativePosition(closestPoint) - position).distance > 40.0) {
        _currentIndex = _addNewPoint(absolutePosition);
      } else {
        _currentIndex = closestIndex;
        _updatePoint(absolutePosition, _currentIndex);
      }
    } else {
      _currentIndex = _addNewPoint(absolutePosition);
    }

    _movementStarted(_currentIndex);
  }

  void registerMoveEvent(Offset position) {
    if (_currentState != TouchState.DOWN && _currentState != TouchState.MOVE) return;
    _currentState = TouchState.MOVE;

    _updatePoint(_convertIntoAbsolutePosition(position), _currentIndex);
  }

  void registerUpEvent(Offset position) {
    if (_currentState != TouchState.DOWN && _currentState != TouchState.MOVE) return;
    _currentState = TouchState.UP;

    _updatePoint(_convertIntoAbsolutePosition(position), _currentIndex);
    _currentIndex = -1;
    _movementFinished();

    _currentState = TouchState.FREE;
  }

  void dispose() {
    _points.close();
    _distances.close();
    _drawingHolder.close();
  }

  Offset _convertIntoAbsolutePosition(Offset position) {
    return (position - _backgroundPosition) / _zoomLevel;
  }

  Offset _convertIntoRelativePosition(Offset position) {
    return position * _zoomLevel + _backgroundPosition;
  }

  List<Offset> _getRelativePoints() {
    return _absolutePoints.map((point) => _convertIntoRelativePosition(point)).toList();
  }

  void _publishPoints() {
    List<Offset> relativePoints = _getRelativePoints();

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

      _callback?.call(distances.map((unit) => unit.value).toList());
    }
  }

  _updatePoints(double factor) {
    _absolutePoints = _absolutePoints.map((Offset point) => point * factor).toList();
    _publishPoints();
  }
}

class _CompareHolder {
  double distance;
  int index;

  _CompareHolder(this.index, this.distance);
}