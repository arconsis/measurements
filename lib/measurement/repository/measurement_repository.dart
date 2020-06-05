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


class MeasurementRepository {
  final _logger = Logger(LogDistricts.MEASUREMENT_REPOSITORY);

  final _points = BehaviorSubject<List<Offset>>.seeded(List());
  final _distances = BehaviorSubject<List<LengthUnit>>.seeded(List());
  final _drawingHolder = BehaviorSubject<DrawingHolder>();

  Function(List<double>) _callback;
  LengthUnit _transformationFactor;

  int _currentIndex = -1;

  MeasurementRepository(MetadataRepository repository) {
    repository.transformationFactor.listen((factor) {
      if (_transformationFactor != factor) {
        _transformationFactor = factor;
        _movementFinished();
      } else {
        _transformationFactor = factor;
      }
    });
    repository.viewScaleFactor.listen((factor) => _updatePoints(factor));
    repository.callback.listen((callback) => _callback = callback);

    _logger.log("Created Repository");
  }

  Stream<List<Offset>> get points => _points.stream;

  Stream<DrawingHolder> get drawingHolder => _drawingHolder.stream;

  void registerDownEvent(Offset position) {
    List<Offset> points = List()
      ..addAll(_points.value);

    int closestIndex = _getClosestPointIndex(points, position);

    if (closestIndex >= 0) {
      Offset closestPoint = points[closestIndex];

      if ((closestPoint - position).distance > 40.0) {
        _currentIndex = _addNewPoint(points, position);
      } else {
        _currentIndex = closestIndex;
        _updatePoint(position, _currentIndex);
      }
    } else {
      _currentIndex = _addNewPoint(points, position);
    }

    _movementStarted(_currentIndex);
  }

  void registerMoveEvent(Offset position) {
    _updatePoint(position, _currentIndex);
  }

  void registerUpEvent(Offset position) {
    _updatePoint(position, _currentIndex);
    _currentIndex = -1;
    _movementFinished();
  }

  void dispose() {
    _points.close();
    _distances.close();
    _drawingHolder.close();
  }

  void _publishPoints(List<Offset> points) {
    _points.add(points);
    _drawingHolder.add(DrawingHolder(points, _distances.value));
  }

  int _addNewPoint(List<Offset> points, Offset point) {
    points.add(point);
    _publishPoints(points);

    _logger.log("added point: $points");
    return points.length - 1;
  }

  void _updatePoint(Offset point, int index) {
    if (index >= 0) {
      List<Offset> points = List()
        ..addAll(_points.value);

      points.setRange(index, index + 1, [point]);
      _publishPoints(points);

      _logger.log("updated point $index: $points");
    }
  }

  int _getClosestPointIndex(List<Offset> points, Offset reference) {
    int index = 0;

    List<_CompareHolder> sortedPoints = points
        .map((Offset point) => _CompareHolder(index++, (reference - point).distance))
        .toList();

    sortedPoints.sort((_CompareHolder a, _CompareHolder b) => a.distance.compareTo(b.distance));

    return sortedPoints.length > 0 ? sortedPoints[0].index : -1;
  }

  void _publishDistances(List<LengthUnit> distances) {
    _distances.add(distances);
    _drawingHolder.add(DrawingHolder(_points.value, distances));
  }

  void _movementStarted(int index) {
    List<LengthUnit> distances = List()
      ..addAll(_distances.value);

    distances.setRange(max(0, index - 1), min(distances.length, index + 1), [null, null]);
    _publishDistances(distances);

    _logger.log("started moving point with index: $index");
  }

  void _movementFinished() {
    List<Offset> points = _points.value;

    if (_transformationFactor != null && points.length >= 2) {
      List<LengthUnit> distances = List();
      points.doInBetween((start, end) => distances.add(_transformationFactor * (start - end).distance));
      _publishDistances(distances);

      if (_callback != null) {
        _callback(distances.map((unit) => unit.value).toList());
      }
    }
  }

  _updatePoints(double factor) {
    final newPoints = _points.value.map((Offset point) => point * factor).toList();
    _publishPoints(newPoints);
  }
}

class _CompareHolder {
  double distance;
  int index;

  _CompareHolder(this.index, this.distance);
}