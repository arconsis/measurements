import 'package:flutter/material.dart';
import 'package:measurements/bloc/bloc_provider.dart';
import 'package:measurements/bloc/measurement_bloc.dart';
import 'package:measurements/overlay/distance_painter.dart';
import 'package:measurements/overlay/measure_painter.dart';
import 'package:measurements/overlay/pointer_handler.dart';
import 'package:measurements/util/logger.dart';

class MeasureArea extends StatefulWidget {
  MeasureArea({Key key, this.paintColor, this.child, this.showDistanceOnLine}) : super(key: key);

  final Color paintColor;
  final bool showDistanceOnLine;
  final Widget child;

  @override
  State<StatefulWidget> createState() => _MeasureState();
}

class _MeasureState extends State<MeasureArea> {
  final Logger logger = Logger(LogDistricts.MEASURE_AREA);

  Offset fromPoint, toPoint;
  double width, height;
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
    Size size = box.size;

    width = size.width;
    height = size.height;
    _bloc.viewWidth = width;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      key: listenerKey,
      onPointerDown: (PointerDownEvent event) {
        handler.registerDownEvent(event);
        logger.log("downEvent $event");
      },
      onPointerMove: (PointerMoveEvent event) {
        handler.registerMoveEvent(event);
        logger.log("moveEvent $event");
      },
      onPointerUp: (PointerUpEvent event) {
        handler.registerUpEvent(event);
        logger.log("upEvent $event");
      },
      child: StreamBuilder(stream: _bloc.distanceStream,
          builder: (BuildContext context, AsyncSnapshot<double> distanceSnapshot) {
            return StreamBuilder(stream: _bloc.pointStream,
                builder: (BuildContext context, AsyncSnapshot<Set<Offset>> points) {
                  Offset first = points?.data?.first,
                      last = points?.data?.last;

                  if (widget.showDistanceOnLine && distanceSnapshot.hasData) {
                    logger.log("drawing with distance");
                    return Stack(
                      children: <Widget>[
                        _pointPainter(first, last),
                        _distancePainter(first, last, distanceSnapshot?.data, width, height),
                      ],);
                  }

                  logger.log("drawing only points");
                  return _pointPainter(first, last);
                });
          }),
    );
  }

  CustomPaint _distancePainter(Offset first, Offset last, double distance, double width, double height) {
    return CustomPaint(
      foregroundPainter: DistancePainter(
          start: first,
          end: last,
          distance: distance,
          width: width,
          height: height,
          drawColor: widget.paintColor
      ),
    );
  }

  CustomPaint _pointPainter(Offset first, Offset last) {
    return CustomPaint(
      foregroundPainter: MeasurePainter(
          start: first,
          end: last,
          paintColor: widget.paintColor
      ),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _bloc?.dispose();
    super.dispose();
  }
}