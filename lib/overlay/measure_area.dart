import 'package:flutter/material.dart';
import 'package:measurements/bloc/bloc_provider.dart';
import 'package:measurements/bloc/measurement_bloc.dart';
import 'package:measurements/overlay/PointerHandler.dart';
import 'package:measurements/overlay/measure_painter.dart';
import 'package:measurements/overlay/point.dart';
import 'package:measurements/util/Logger.dart';

class MeasureArea extends StatefulWidget {
  MeasureArea({Key key, this.paintColor, this.child}) : super(key: key);

  final Color paintColor;
  final Widget child;

  @override
  State<StatefulWidget> createState() => _MeasureState();
}

class _MeasureState extends State<MeasureArea> {
  Point fromPoint, toPoint;
  MeasurementBloc _bloc;
  PointerHandler handler;
  GlobalKey listenerKey = GlobalKey();

  @override
  void initState() {
    _bloc = BlocProvider.of(context);
    handler = PointerHandler(_bloc);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateSize());

    super.initState();
  }

  @override
  void didUpdateWidget(MeasureArea oldWidget) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateSize());
    super.didUpdateWidget(oldWidget);
  }

  void _updateSize() {
    RenderBox box = listenerKey.currentContext.findRenderObject();

    _bloc.viewWidth = box.size.width;
    _bloc.getZoomFactorForOriginalSize();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      key: listenerKey,
      onPointerDown: (PointerDownEvent event) {
        handler.registerDownEvent(event);
        Logger.log("downEvent", LogDistricts.MEASURE_AREA);

        _updatePointState();
      },
      onPointerMove: (PointerMoveEvent event) {
        handler.registerMoveEvent(event);
        Logger.log("moveEvent", LogDistricts.MEASURE_AREA);

        _updatePointState();
      },
      onPointerUp: (PointerUpEvent event) {
        handler.registerUpEvent(event);
        Logger.log("upEvent", LogDistricts.MEASURE_AREA);

        _updatePointState();
      },
      child: CustomPaint(
        foregroundPainter: MeasurePainter(
            fromPoint: fromPoint,
            toPoint: toPoint,
            paintColor: widget.paintColor),
        child: widget.child,
      ),
    );
  }

  void _updatePointState() {
    setState(() {
      fromPoint = handler.fromPoint;
      toPoint = handler.toPoint;
    });
  }
}