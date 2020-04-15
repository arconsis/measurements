import 'package:flutter/material.dart';
import 'package:measurements/bloc/bloc_provider.dart';
import 'package:measurements/bloc/measurement_bloc.dart';
import 'package:measurements/overlay/distance_painter.dart';
import 'package:measurements/overlay/measure_painter.dart';
import 'package:measurements/overlay/pointer_handler.dart';
import 'package:measurements/util/logger.dart';
import 'package:measurements/util/utils.dart';

class MeasureArea extends StatefulWidget {
  MeasureArea({Key key, this.paintColor, this.child}) : super(key: key);

  final Color paintColor;
  final Widget child;

  @override
  State<StatefulWidget> createState() => _MeasureState();
}

class _MeasureState extends State<MeasureArea> {
  final Logger logger = Logger(LogDistricts.MEASURE_AREA);

  double width, height;
  MeasurementBloc _bloc;
  PointerHandler handler;
  GlobalKey listenerKey = GlobalKey();

  @override
  void didChangeDependencies() {
    _bloc = BlocProvider.of(context);
    handler = PointerHandler(_bloc);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateSize());

    super.didChangeDependencies();
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
        // TODO combine Streams to avoid double execution on updates. Look at updates to streams in bloc
        child: StreamBuilder(
          initialData: _bloc.measure,
          stream: _bloc.measureStream,
          builder: (BuildContext context, AsyncSnapshot<bool> measure) {
            return StreamBuilder(
                initialData: _bloc.showDistance,
                stream: _bloc.showDistanceStream,
                builder:
                    (BuildContext context, AsyncSnapshot<bool> showDistance) {
                  return StreamBuilder(
                      initialData: _bloc.distances,
                      stream: _bloc.distancesStream,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<double>> distanceSnapshot) {
                        return StreamBuilder(
                            //132: we do not need initial value here
                            stream: _bloc.pointsStream,
                            builder: (BuildContext context,
                                AsyncSnapshot<List<Offset>> points) {
                              if (points.hasData) {
                                return _buildOverlays(
                                    points, showDistance, distanceSnapshot);
                              } else {
                                return _buildOverlays(
                                    points, showDistance, distanceSnapshot);
                              }
                            });
                      });
                });
          },
        ));
  }

  Widget _buildOverlays(
      AsyncSnapshot<List<Offset>> points,
      AsyncSnapshot<bool> showDistance,
      AsyncSnapshot<List<double>> distanceSnapshot) {
    List<Widget> painters = List();

    if (points.hasData && points.data.length >= 2) {
      List<Holder> holders = List();
      points.data.doInBetween((start, end) => holders.add(Holder(start, end)));

      if (_canDrawDistances(showDistance, distanceSnapshot)) {
        holders.zip(distanceSnapshot.data,
            (Holder holder, double distance) => holder.distance = distance);

        painters = holders
            .map((Holder holder) => [
                  _pointPainter(holder.first, holder.second),
                  _distancePainter(holder.first, holder.second, holder.distance,
                      width, height)
                ])
            .expand((pair) => pair)
            .toList();

        logger.log("drawing with distance: $holders");
      } else {
        painters = holders
            .map((Holder holder) => _pointPainter(holder.first, holder.second))
            .toList();

        logger.log("drawing multiple points ${points.data}");
      }
    } else {
      Offset first, last;

      if (points.data != null && points.data.isNotEmpty) {
        first = points?.data?.first;
        last = points?.data?.last;
      }

      if (first != null && last != null) {
        painters = [_pointPainter(first, last)];
        logger.log("drawing one point ${points.data}");
      } else {
        logger.log("drawing no points");
      }
    }

    List<Widget> children = List();
    children.add(widget.child);
    children.addAll(painters);

    return Stack(
      children: children,
    );
  }

  bool _canDrawDistances(AsyncSnapshot<bool> showDistance,
          AsyncSnapshot<List<double>> distanceSnapshot) =>
      showDistance.hasData &&
      showDistance.data &&
      distanceSnapshot.hasData &&
      width != null &&
      height != null;

  CustomPaint _distancePainter(
      Offset first, Offset last, double distance, double width, double height) {
    return CustomPaint(
      foregroundPainter: DistancePainter(
          start: first,
          end: last,
          distance: distance,
          width: width,
          height: height,
          drawColor: widget.paintColor),
    );
  }

  CustomPaint _pointPainter(Offset first, Offset last) {
    return CustomPaint(
      foregroundPainter: MeasurePainter(
          start: first, end: last, paintColor: widget.paintColor),
    );
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
