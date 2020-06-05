///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:measurements/measurement/bloc/measure_bloc/measure_bloc.dart';
import 'package:measurements/measurement/bloc/measure_bloc/measure_event.dart';
import 'package:measurements/measurement/bloc/measure_bloc/measure_state.dart';
import 'package:measurements/measurement/bloc/points_bloc/points_bloc.dart';
import 'package:measurements/measurement/bloc/points_bloc/points_state.dart';
import 'package:measurements/metadata/measurement_information.dart';
import 'package:measurements/style/distance_style.dart';
import 'package:measurements/style/magnification_style.dart';
import 'package:measurements/style/point_style.dart';
import 'package:measurements/util/logger.dart';
import 'package:measurements/util/utils.dart';

import 'painters/distance_painter.dart';
import 'painters/magnifying_painter.dart';
import 'painters/measure_painter.dart';

class MeasureArea extends StatelessWidget {
  final _logger = Logger(LogDistricts.MEASURE_AREA);

  final Widget child;
  final PointStyle pointStyle;
  final MagnificationStyle magnificationStyle;
  final DistanceStyle distanceStyle;

  MeasureArea({@required this.child, @required this.pointStyle, @required this.magnificationStyle, @required this.distanceStyle});

  @override
  Widget build(BuildContext context) {
    return Listener(
        onPointerDown: (PointerDownEvent event) =>
            BlocProvider.of<MeasureBloc>(context).add(MeasureDownEvent(event.localPosition)),
        onPointerMove: (PointerMoveEvent event) =>
            BlocProvider.of<MeasureBloc>(context).add(MeasureMoveEvent(event.localPosition)),
        onPointerUp: (PointerUpEvent event) =>
            BlocProvider.of<MeasureBloc>(context).add(MeasureUpEvent(event.localPosition)),
        child: Stack(
          children: <Widget>[
            BlocBuilder<PointsBloc, PointsState>(
              builder: (context, state) => _pointsOverlay(state, child),
            ),
            BlocBuilder<MeasureBloc, MeasureState>(
              builder: (context, state) => _magnificationOverlay(state),
            ),
          ],
        )
    );
  }

  Stack _pointsOverlay(PointsState state, Widget child) {
    List<Widget> widgets = List.of([child]);

    if (state is PointsSingleState) {
      widgets.add(_pointPainter(state.point, state.point));
    } else if (state is PointsOnlyState) {
      widgets.addAll(_onlyPoints(state));
    } else if (state is PointsAndDistanceActiveState) {
      widgets.addAll(_pointsAndDistancesWithSpace(state));
    } else if (state is PointsAndDistanceState) {
      widgets.addAll(_pointsAndDistances(state));
    }

    return Stack(children: widgets,);
  }

  List<Widget> _onlyPoints(PointsOnlyState state) {
    List<Widget> widgets = List();

    state.points.doInBetween((start, end) => widgets.add(_pointPainter(start, end)));

    return widgets;
  }

  Iterable<Widget> _pointsAndDistancesWithSpace(PointsAndDistanceActiveState state) {
    List<Widget> widgets = List();

    state.holders.asMap().forEach((index, holder) {
      widgets.add(_pointPainter(holder.start, holder.end));
      if (!state.nullIndices.contains(index)) {
        widgets.add(_distancePainter(holder.start, holder.end, holder.distance, state.tolerance, state.viewCenter));
      }
    });

    return widgets;
  }

  List<Widget> _pointsAndDistances(PointsAndDistanceState state) {
    List<Widget> widgets = List();

    state.holders.forEach((holder) {
      widgets.add(_pointPainter(holder.start, holder.end));
      widgets.add(_distancePainter(holder.start, holder.end, holder.distance, state.tolerance, state.viewCenter));
    });

    return widgets;
  }

  CustomPaint _pointPainter(Offset first, Offset last) {
    return CustomPaint(
      foregroundPainter: MeasurePainter(
        start: first,
        end: last,
        style: pointStyle,
      ),
    );
  }

  CustomPaint _distancePainter(Offset first, Offset last, LengthUnit distance, double tolerance, Offset viewCenter) {
    return CustomPaint(
      foregroundPainter: DistancePainter(
        start: first,
        end: last,
        distance: distance,
        tolerance: tolerance,
        viewCenter: viewCenter,
        style: distanceStyle,
      ),
    );
  }

  Widget _magnificationOverlay(MeasureState state) {
    if (state is MeasureActiveState) {
      return CustomPaint(
        foregroundPainter: MagnifyingPainter(
          fingerPosition: state.position,
          image: state.backgroundImage,
          imageScaleFactor: state.imageScaleFactor,
          style: magnificationStyle,
          magnificationOffset: state.magnificationOffset,
        ),
      );
    }

    return Opacity(opacity: 0.0,);
  }
}