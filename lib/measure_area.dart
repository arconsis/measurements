import 'package:flutter/material.dart';
import 'package:measurements/bloc/bloc_provider.dart';
import 'package:measurements/measure_painter.dart';
import 'package:measurements/measurement_bloc.dart';
import 'package:measurements/point.dart';

class MeasureArea extends StatefulWidget {
  MeasureArea({Key key, this.paintColor}) : super(key: key);

  final Color paintColor;

  @override
  State<StatefulWidget> createState() => _MeasureState();
}

class _MeasureState extends State<MeasureArea> {
  Point fromPoint, toPoint;
  MeasurementBloc _bloc;

  @override
  void initState() {
    _bloc = BlocProvider.of(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;

    return Listener(
      onPointerDown: (PointerDownEvent event) {
        setState(() {
          fromPoint = Point(pos: event.localPosition);
          toPoint = null;
        });

        _bloc.fromPoint.add(fromPoint);
        _bloc.toPoint.add(toPoint);
      },
      onPointerMove: (PointerMoveEvent event) {
        setState(() {
          toPoint = Point(pos: event.localPosition);
        });

        _bloc.toPoint.add(toPoint);
      },
      onPointerUp: (PointerUpEvent event) {
        setState(() {
          toPoint = Point(pos: event.localPosition);
        });

        _bloc.toPoint.add(toPoint);
      },
      child: CustomPaint(
          size: size,
          painter:
          MeasurePainter(fromPoint: fromPoint, toPoint: toPoint, paintColor: widget.paintColor)),
    );
  }
}
