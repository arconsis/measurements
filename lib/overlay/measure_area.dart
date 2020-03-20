import 'package:flutter/material.dart';
import 'package:measurements/bloc/bloc_provider.dart';
import 'package:measurements/bloc/measurement_bloc.dart';
import 'package:measurements/overlay/PointerHandler.dart';
import 'package:measurements/overlay/measure_painter.dart';
import 'package:measurements/util/Logger.dart';

class MeasureArea extends StatefulWidget {
  MeasureArea({Key key, this.paintColor, this.child}) : super(key: key);

  final Color paintColor;
  final Widget child;

  @override
  State<StatefulWidget> createState() => _MeasureState();
}

class _MeasureState extends State<MeasureArea> {
  Offset fromPoint, toPoint;
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
    Size viewSize = box.size;

    _bloc.viewWidth = viewSize.width;
    _bloc.viewHeight = viewSize.height;
    _bloc.viewOffset = box.localToGlobal(Offset(0.0, 0.0));
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      key: listenerKey,
      onPointerDown: (PointerDownEvent event) {
        handler.registerDownEvent(event);
        Logger.log("downEvent", LogDistricts.MEASURE_AREA);
      },
      onPointerMove: (PointerMoveEvent event) {
        handler.registerMoveEvent(event);
        Logger.log("moveEvent", LogDistricts.MEASURE_AREA);
      },
      onPointerUp: (PointerUpEvent event) {
        handler.registerUpEvent(event);
        Logger.log("upEvent", LogDistricts.MEASURE_AREA);
      },
      child: StreamBuilder(stream: _bloc.pointStream,
          builder: (BuildContext context, AsyncSnapshot<Set<Offset>> points) {
            return CustomPaint(
              foregroundPainter: MeasurePainter(
                  fromPoint: points?.data?.first,
                  toPoint: points?.data?.last,
                  paintColor: widget.paintColor
              ),
              child: widget.child,
            );
          }),
    );
  }

  @override
  void dispose() {
    _bloc?.dispose();
    super.dispose();
  }
}