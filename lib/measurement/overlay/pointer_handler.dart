import 'package:flutter/material.dart';
import 'package:measurements/measurement/bloc/measurement_bloc.dart';
import 'package:measurements/util/logger.dart';

class PointerHandler {
  final Logger logger = Logger(LogDistricts.POINTER_HANDLER);
  MeasurementBlocOld _bloc;

  PointerHandler(this._bloc);

  int _currentIndex = -1;

  void registerDownEvent(PointerDownEvent event) {
    Offset eventPoint = event.localPosition;

    int closestIndex = _bloc.getClosestPointIndex(eventPoint);
    if (closestIndex >= 0) {
      Offset closestPoint = _bloc.getPoint(closestIndex);

      if ((closestPoint - eventPoint).distance > 40.0) {
        _addNewPoint(eventPoint);
      } else {
        _currentIndex = closestIndex;

        _bloc.updatePoint(eventPoint, closestIndex);
      }
    } else {
      _addNewPoint(eventPoint);
    }

    _bloc.movementStarted(_currentIndex);
  }

  void _addNewPoint(Offset eventPoint) {
    _currentIndex = _bloc.addPoint(eventPoint);
  }

  void _updatePoint(Offset eventPoint) {
    if (_currentIndex >= 0) {
      _bloc.updatePoint(eventPoint, _currentIndex);
    }
  }

  void registerMoveEvent(PointerMoveEvent event) {
    _updatePoint(event.localPosition);
  }

  void registerUpEvent(PointerUpEvent event) {
    _updatePoint(event.localPosition);
    _currentIndex = -1;
    _bloc.movementFinished();
  }
}
