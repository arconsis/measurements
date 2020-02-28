import 'package:flutter/material.dart';
import 'package:measurements/bloc/bloc_provider.dart';
import 'package:measurements/measure_painter.dart';
import 'package:measurements/measurement_bloc.dart';
import 'package:measurements/point.dart';

class MeasureArea extends StatefulWidget {
  MeasureArea({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MeasureState();
}

class _MeasureState extends State<MeasureArea> {
  Point fromPoint, toPoint;
  MeasurementBloc _bloc;

  double lastDistance;

  @override
  void initState() {
    _bloc = BlocProvider.of(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double dist = -1.0;

    if (fromPoint != null && toPoint != null) {
      dist = (fromPoint - toPoint).length();

      if (dist != lastDistance) {
        lastDistance = dist;
        _bloc?.setPixelDistance(dist);
      }
    }

    Size size = MediaQuery
        .of(context)
        .size;

    return Listener(
      onPointerDown: (PointerDownEvent event) {
        setState(() {
          fromPoint = Point(pos: event.localPosition);
          toPoint = null;
        });
      },
      onPointerMove: (PointerMoveEvent event) {
        setState(() {
          toPoint = Point(pos: event.localPosition);
        });
      },
      onPointerUp: (PointerUpEvent event) {
        setState(() {
          toPoint = Point(pos: event.localPosition);
        });
      },
      child: CustomPaint(
          size: size,
          painter:
          MeasurePainter(fromPoint: fromPoint, toPoint: toPoint)),
    );
  }
}
