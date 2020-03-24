import 'dart:math';

import 'package:flutter/material.dart';
import 'package:measurements/bloc/measurement_bloc.dart';

enum ActionType {
  NEW_POINT,
  UPDATE_POINT,
}

class Action {
  int index;
  ActionType type;

  Action(this.type, {this.index});
}

class PointerHandler {
  MeasurementBloc _bloc;

  PointerHandler(this._bloc);

  Offset fromPoint, toPoint;
  Action currentAction;

  void registerDownEvent(PointerDownEvent event) {
    Offset eventPoint = event.localPosition;
    double distanceToFirstPoint = double.maxFinite;
    double distanceToSecondPoint = double.maxFinite;

    if (fromPoint != null && toPoint != null) {
      distanceToFirstPoint = (eventPoint - fromPoint)?.distance;
      distanceToSecondPoint = (eventPoint - toPoint)?.distance;
    }

    if (min(distanceToFirstPoint, distanceToSecondPoint) > 40.0) {
      currentAction = Action(ActionType.NEW_POINT);
    } else if (distanceToFirstPoint < distanceToSecondPoint) {
//      currentAction = ActionType.MOVE_FIRST_POINT;
    } else {
//      currentAction = ActionType.MOVE_SECOND_POINT;
    }

    switch (currentAction.type) {
//      case ActionType.MOVE_FIRST_POINT:
//        fromPoint = eventPoint;
//
//        _bloc.fromPoint = fromPoint;
//        break;
//      case ActionType.MOVE_SECOND_POINT:
//        toPoint = eventPoint;
//
//        _bloc.toPoint = toPoint;
//        break;
      case ActionType.NEW_POINT:
      default:
        int index = _bloc.addPoint(eventPoint);
        currentAction.index = index;
        break;
    }
  }

  void _updatePoints(Offset eventPoint) {
    switch (currentAction.type) {
//      case ActionType.MOVE_FIRST_POINT:
//        fromPoint = eventPoint;
//
//        _bloc.fromPoint = fromPoint;
//        break;
//      case ActionType.MOVE_SECOND_POINT:
//        toPoint = eventPoint;
//
//        _bloc.toPoint = toPoint;
//        break;
      case ActionType.NEW_POINT:
      default:
        _bloc.updatePoint(eventPoint, currentAction.index);
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
