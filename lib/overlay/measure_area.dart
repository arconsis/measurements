import 'package:flutter/material.dart';
import 'package:measurements/bloc/bloc_provider.dart';
import 'package:measurements/bloc/measurement_bloc.dart';
import 'package:measurements/overlay/distance_painter.dart';
import 'package:measurements/overlay/measure_painter.dart';
import 'package:measurements/overlay/pointer_handler.dart';
import 'package:measurements/util/logger.dart';
import 'package:measurements/util/utils.dart';

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
      // TODO combine Streams to avoid double execution on updates
      child: StreamBuilder(stream: _bloc.distancesStream,
          builder: (BuildContext context, AsyncSnapshot<List<double>> distanceSnapshot) {
            return StreamBuilder(stream: _bloc.pointsStream,
                builder: (BuildContext context, AsyncSnapshot<List<Offset>> points) {
                  return _buildOverlays(points, distanceSnapshot);
                });
          }),
    );
  }

  Widget _buildOverlays(AsyncSnapshot<List<Offset>> points, AsyncSnapshot<List<double>> distanceSnapshot) {
    List<Widget> painters;

    if (points.hasData && points.data.length >= 2) {
      List<Holder> holders = List();
      points.data.doInBetween((start, end) => holders.add(Holder(start, end)));

      if (widget.showDistanceOnLine && distanceSnapshot.hasData) {
        holders.zip(distanceSnapshot.data, (Holder holder, double distance) => holder.distance = distance);

        painters = holders
            .map((Holder holder) =>
        [
          _pointPainter(holder.first, holder.second),
          _distancePainter(holder.first, holder.second, holder.distance, width, height)
        ])
            .expand((pair) => pair)
            .toList();

        logger.log("drawing with distance");
      } else {
        painters = holders
            .map((Holder holder) => _pointPainter(holder.first, holder.second))
            .toList();

        logger.log("drawing multiple points ${points.data}");
      }
    } else {
      Offset first = points?.data?.first,
          last = points?.data?.last;

      painters = [_pointPainter(first, last)];

      logger.log("drawing one point ${points.data}");
    }

    List<Widget> children = List();
    children.add(widget.child);
    children.addAll(painters);

    return Stack(children: children,);
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
    );
  }

  @override
  void dispose() {
    _bloc?.dispose();
    super.dispose();
  }
}

class Holder {
  Offset first, second;
  double distance;

  Holder(this.first, this.second);

  @override
  String toString() {
    return "First Point: $first - Second Point: $second - Distance: $distance";
  }
}