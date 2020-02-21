import 'package:flutter/material.dart';
import 'package:measurements/bloc/bloc_provider.dart';
import 'package:measurements/measure_painter.dart';
import 'package:measurements/measurement_bloc.dart';
import 'package:measurements/point.dart';

class MeasureArea extends StatefulWidget {
  MeasureArea({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _MeasureState();
}

class _MeasureState extends State<MeasureArea> {
  Point downPoint, upPoint;
  MeasurementBloc _bloc;

  @override
  void initState() {
    _bloc = BlocProvider.of(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double dist = -1.0;

    if (downPoint != null && upPoint != null) {
      dist = (downPoint - upPoint).length();

      _bloc.setPixelDistance(dist);
      _bloc.setMeasurementPointsSet(true);
    } else {
      _bloc.setMeasurementPointsSet(false);
    }

    Size size = MediaQuery
        .of(context)
        .size;

    return Listener(
      onPointerDown: (PointerDownEvent event) {
        setState(() {
          downPoint = new Point(pos: event.localPosition);
          upPoint = null;
        });

        print("Down");
      },
      onPointerMove: (PointerMoveEvent event) {
        setState(() {
          upPoint = new Point(pos: event.localPosition);
        });
      },
      onPointerUp: (PointerUpEvent event) {
        setState(() {
          upPoint = new Point(pos: event.localPosition);
        });
      },
      child: CustomPaint(
          size: size,
          painter:
          MeasurePainter(downPoint: downPoint, upPoint: upPoint)),
    );
  }
}
