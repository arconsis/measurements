import 'package:flutter/material.dart';
import 'package:measurements/bloc/bloc_provider.dart';
import 'package:measurements/bloc/measurement_bloc.dart';
import 'package:measurements/overlay/PointerHandler.dart';
import 'package:measurements/overlay/measure_painter.dart';
import 'package:measurements/overlay/point.dart';

class MeasureArea extends StatefulWidget {
  MeasureArea({Key key, this.paintColor}) : super(key: key);

  final Color paintColor;

  @override
  State<StatefulWidget> createState() => _MeasureState();
}

class _MeasureState extends State<MeasureArea> {
  Point fromPoint, toPoint;
  MeasurementBloc _bloc;
  PointerHandler handler;

  @override
  void initState() {
    _bloc = BlocProvider.of(context);
    handler = PointerHandler(_bloc);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;

    return Listener(
      onPointerDown: (PointerDownEvent event) {
        handler.registerDownEvent(event);

        _updatePointState();
      },
      onPointerMove: (PointerMoveEvent event) {
        handler.registerMoveEvent(event);

        _updatePointState();
      },
      onPointerUp: (PointerUpEvent event) {
        handler.registerUpEvent(event);

        _updatePointState();
      },
      child: CustomPaint(
          size: size,
          painter:
          MeasurePainter(fromPoint: fromPoint, toPoint: toPoint, paintColor: widget.paintColor)),
    );
  }

  void _updatePointState() {
    setState(() {
      fromPoint = handler.fromPoint;
      toPoint = handler.toPoint;
    });
  }
}