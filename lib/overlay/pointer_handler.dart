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

  Action currentAction;

  void registerDownEvent(PointerDownEvent event) {
    Offset eventPoint = event.localPosition;

    int closestIndex = _bloc.getClosestPointIndex(eventPoint);
    if (closestIndex >= 0) {
      Offset closestPoint = _bloc.getPoint(closestIndex);

      if ((closestPoint - eventPoint).distance > 40.0) {
        addNewPoint(eventPoint);
      } else {
        currentAction = Action(ActionType.UPDATE_POINT, index: closestIndex);

        _bloc.updatePoint(eventPoint, closestIndex);
      }
    } else {
      addNewPoint(eventPoint);
    }
  }

  void addNewPoint(Offset eventPoint) {
    currentAction = Action(ActionType.NEW_POINT);

    int index = _bloc.addPoint(eventPoint);
    currentAction.index = index;
  }

  void _updatePoints(Offset eventPoint) {
    switch (currentAction.type) {
      case ActionType.UPDATE_POINT:
        _bloc.updatePoint(eventPoint, currentAction.index);
        break;
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
