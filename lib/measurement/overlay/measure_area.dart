import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:measurements/measurement/bloc/measure_bloc/measure_bloc.dart';
import 'package:measurements/measurement/bloc/measure_bloc/measure_event.dart';
import 'package:measurements/measurement/bloc/measure_bloc/measure_state.dart';
import 'package:measurements/measurement/bloc/points_bloc/points_bloc.dart';
import 'package:measurements/measurement/bloc/points_bloc/points_state.dart';
import 'package:measurements/util/utils.dart';

import 'holder.dart';
import 'painters/distance_painter.dart';
import 'painters/magnifying_painter.dart';
import 'painters/measure_painter.dart';

class MeasureArea extends StatelessWidget {
  final Color paintColor;
  final Widget child;

  MeasureArea({this.paintColor, @required this.child});

  @override
  Widget build(BuildContext context) {
    return Listener(
        onPointerDown: (PointerDownEvent event) {
          BlocProvider.of<MeasureBloc>(context).add(MeasureDownEvent(event.localPosition));
        },
        onPointerMove: (PointerMoveEvent event) {
          BlocProvider.of<MeasureBloc>(context).add(MeasureMoveEvent(event.localPosition));
        },
        onPointerUp: (PointerUpEvent event) {
          BlocProvider.of<MeasureBloc>(context).add(MeasureUpEvent(event.localPosition));
        },

        child: Stack(
          children: <Widget>[
            child,
            BlocBuilder<PointsBloc, PointsState>(
              builder: (context, state) => _pointsOverlay(state),
            ),
            BlocBuilder<MeasureBloc, MeasureState>(
              builder: (context, state) => _magnificationOverlay(state),
            ),
          ],
        )
    );
  }

  Stack _pointsOverlay(PointsState state) {
    List<Widget> widgets = List();

    if (state is PointsOnlyState) {
      widgets = _onlyPoints(state);
    } else if (state is PointsAndDistanceState) {
      widgets = _pointsAndDistances(state);
    }

    return Stack(children: widgets,);
  }

  List<Widget> _onlyPoints(PointsOnlyState state) {
    List<Widget> widgets = List();

    if (state.points.length > 1) {
      // TODO check if if-else is needed for distances (too?)
      state.points.doInBetween((start, end) => widgets.add(_pointPainter(start, end)));
    } else {
      Offset first = state.points.first;
      widgets.add(_pointPainter(first, first));
    }

    return widgets;
  }

  CustomPaint _pointPainter(Offset first, Offset last) {
    return CustomPaint(
      foregroundPainter: MeasurePainter(
          start: first,
          end: last,
          paintColor: paintColor
      ),
    );
  }

  List<Widget> _pointsAndDistances(PointsAndDistanceState state) {
    List<Widget> widgets = List();
    List<Holder> holders = List();

    state.points.doInBetween((start, end) => holders.add(Holder(start, end)));
    state.distances.zip(holders, (double distance, Holder holder) => holder.distance = distance);

    holders.forEach((holder) => widgets.add(_distancePainter(holder.start, holder.end, holder.distance, state.viewCenter)));

    return widgets;
  }

  CustomPaint _distancePainter(Offset first, Offset last, double distance, Offset viewCenter) {
    return CustomPaint(
      foregroundPainter: DistancePainter(
          start: first,
          end: last,
          distance: distance,
          viewCenter: viewCenter,
          drawColor: paintColor
      ),
    );
  }

  Widget _magnificationOverlay(MeasureState state) {
    if (state is MeasureActiveState) {
      return CustomPaint(
        foregroundPainter: MagnifyingPainter(
            fingerPosition: state.position,
            image: state.backgroundImage,
            radius: state.magnificationRadius,
            imageScaleFactor: state.imageScaleFactor
        ),
      );
    }

    return Opacity(opacity: 0.0,);
  }
}