import 'dart:math';
import 'dart:ui';

import 'package:get_it/get_it.dart';
import 'package:measurements/measurement/bloc/measure_bloc/drawing_holder.dart';
import 'package:measurements/metadata/repository/metadata_repository.dart';
import 'package:measurements/util/logger.dart';
import 'package:measurements/util/utils.dart';
import 'package:rxdart/rxdart.dart';


class MeasurementRepository {
  final _logger = Logger(LogDistricts.MEASUREMENT_REPOSITORY);

  final _points = BehaviorSubject<List<Offset>>();
  final _distances = BehaviorSubject<List<double>>();
  final _drawingHolder = BehaviorSubject<DrawingHolder>();

  Function(List<double>) _callback;
  double _transformationFactor = 0.0;

  int _currentIndex = -1;

  MeasurementRepository() {
    _logger.log("Created Repository");

    MetadataRepository repository = GetIt.I<MetadataRepository>();

    repository.transformationFactor.listen((factor) => _transformationFactor = factor);
    repository.callback.listen((callback) => _callback = callback);
  }

  Stream<List<Offset>> get points => _points.stream;

  Stream<DrawingHolder> get drawingHolder => _drawingHolder.stream;

  void registerDownEvent(Offset position) async {
    List<Offset> points = await _points.last;
    int closestIndex = _getClosestPointIndex(points, position);

    if (closestIndex >= 0) {
      Offset closestPoint = points[closestIndex];

      if ((closestPoint - position).distance > 40.0) {
        _currentIndex = await _addNewPoint(points, position);
      } else {
        _currentIndex = closestIndex;
        _updatePoint(position, _currentIndex);
      }
    } else {
      _currentIndex = await _addNewPoint(points, position);
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

  void _registerNewPoints(List<Offset> points) async {
    _points.add(points);
    _drawingHolder.add(DrawingHolder(points, await _distances.last));
  }

  Future<int> _addNewPoint(List<Offset> points, Offset point) async {
    points.add(point);
    _registerNewPoints(points);

    _logger.log("added point: $_points");
    return points.length - 1;
  }

  void _updatePoint(Offset point, int index) async {
    if (index >= 0) {
      List<Offset> points = await _points.last;

      points.setRange(index, index + 1, [point]);
      _registerNewPoints(points);

      _logger.log("updated point $index: $_points");
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

  void _movementStarted(int index) async {
    List<double> distances = await _distances.last;

    distances.setRange(max(0, index - 1), min(distances.length, index + 1), [null, null]);
    _distances.add(distances);
    _drawingHolder.add(DrawingHolder(await _points.last, distances));

    _logger.log("started moving point with index: $index");
  }

  void _movementFinished() async {
    List<Offset> points = await _points.last;

    if (_transformationFactor != null && _transformationFactor != 0.0 && points.length >= 2) {
      List<double> distances = List();

      points.doInBetween((start, end) => distances.add((start - end).distance * _transformationFactor));

      _distances.add(distances);
      _drawingHolder.add(DrawingHolder(points, distances));

      if (_callback != null) {
        _callback(distances);
      }
    }
  }
}

class _CompareHolder {
  double distance;
  int index;

  _CompareHolder(this.index, this.distance);
}