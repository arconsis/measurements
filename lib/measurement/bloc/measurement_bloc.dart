import 'package:flutter/material.dart';
import 'package:measurements/util/logger.dart';

class MeasurementBlocOld {
//  final Logger logger = Logger(LogDistricts.BLOC);

  bool _didUpdateOrientation = true;
  Orientation _orientation;
  Orientation _lastOrientation;
  double _viewWidth;
  double _lastViewWidth;

  set orientation(Orientation orientation) {
    if (_orientation != orientation) {
      _lastOrientation = _orientation;
      _didUpdateOrientation = false;

      _orientation = orientation;
//      logger.log("oriantation: $orientation");

      _updatePointsToOrientation();
    }
  }

  set viewWidth(double width) {
    if (width != _viewWidth) {
      _lastViewWidth = _viewWidth;
      _didUpdateOrientation = false;

      _viewWidth = width;
//      logger.log("viewWidth: $_viewWidth");

//      _updateTransformationFactor();
      _updatePointsToOrientation();
    }
  }

  void _updatePointsToOrientation() {
    if (!_didUpdateOrientation && _lastOrientation != null && _lastViewWidth != null) {
      double scale = _viewWidth / _lastViewWidth;

//      List<Offset> scaledPoints = _points.map((Offset point) => point * scale).toList();
//
//      _pointsController.add(scaledPoints);

      _didUpdateOrientation = true;
      _lastOrientation = null;
      _lastViewWidth = null;

//      logger.log("updated points to orientation");
    }
  }
}
