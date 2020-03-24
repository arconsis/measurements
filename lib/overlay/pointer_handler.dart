import 'dart:math';

import 'package:flutter/material.dart';
import 'package:measurements/bloc/measurement_bloc.dart';

enum ActionType {
  NEW_POINT,
  MOVE_FIRST_POINT,
  MOVE_SECOND_POINT,
}

class PointerHandler {
  MeasurementBloc _bloc;

  PointerHandler(this._bloc);

  Offset fromPoint, toPoint;
  ActionType currentAction;

  void registerDownEvent(PointerDownEvent event) {
    Offset eventPoint = event.localPosition;
    double distanceToFirstPoint = double.maxFinite;
    double distanceToSecondPoint = double.maxFinite;

    if (fromPoint != null && toPoint != null) {
      distanceToFirstPoint = (eventPoint - fromPoint)?.distance;
      distanceToSecondPoint = (eventPoint - toPoint)?.distance;
    }

    if (min(distanceToFirstPoint, distanceToSecondPoint) > 40.0) {
      currentAction = ActionType.NEW_POINT;
    } else if (distanceToFirstPoint < distanceToSecondPoint) {
      currentAction = ActionType.MOVE_FIRST_POINT;
    } else {
      currentAction = ActionType.MOVE_SECOND_POINT;
    }

    switch (currentAction) {
      case ActionType.MOVE_FIRST_POINT:
        fromPoint = eventPoint;

        _bloc.fromPoint = fromPoint;
        break;
      case ActionType.MOVE_SECOND_POINT:
        toPoint = eventPoint;

        _bloc.toPoint = toPoint;
        break;
      case ActionType.NEW_POINT:
      default:
        fromPoint = eventPoint;
        toPoint = eventPoint;

        _bloc.fromPoint = fromPoint;
        _bloc.toPoint = toPoint;
        break;
    }
  }

  void _updatePoints(Offset eventPoint) {
    switch (currentAction) {
      case ActionType.MOVE_FIRST_POINT:
        fromPoint = eventPoint;

        _bloc.fromPoint = fromPoint;
        break;
      case ActionType.MOVE_SECOND_POINT:
        toPoint = eventPoint;

        _bloc.toPoint = toPoint;
        break;
      case ActionType.NEW_POINT:
      default:
        toPoint = eventPoint;

        _bloc.toPoint = toPoint;
        break;
    }
  }

  void _updateEventPoint(PointerEvent event) {
    _updatePoints(event.localPosition);
  }

  void registerMoveEvent(PointerMoveEvent event) {
    _updateEventPoint(event);
  }

  void registerUpEvent(PointerUpEvent event) {
    _updateEventPoint(event);
  }
}
