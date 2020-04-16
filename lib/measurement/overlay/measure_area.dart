import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:measurements/measurement/bloc/measurement_bloc.dart';
import 'package:measurements/measurement/overlay/pointer_handler.dart';
import 'package:measurements/util/logger.dart';
import 'package:measurements/util/size.dart';
import 'package:measurements/util/utils.dart';

import 'holder.dart';
import 'painters/distance_painter.dart';
import 'painters/magnifying_painter.dart';
import 'painters/measure_painter.dart';

class MeasureArea extends StatelessWidget {
  final Color paintColor;
  final Widget child;

  MeasureArea({this.paintColor, @required this.child});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return null;
  }
}

class MeasureAreaOld extends StatefulWidget {
  MeasureAreaOld({Key key, this.paintColor, this.child}) : super(key: key);

  final Color paintColor;
  final Widget child;

  @override
  State<StatefulWidget> createState() => _MeasureState();
}

class _MeasureState extends State<MeasureAreaOld> {
  final Logger logger = Logger(LogDistricts.MEASURE_AREA);

  Offset viewCenter, fingerPosition;
  Size viewSize;
  MeasurementBloc _bloc;
  PointerHandler handler;
  GlobalKey listenerKey = GlobalKey();
  bool showMagnifyingGlass = false;

  @override
  void didChangeDependencies() {
//    handler = PointerHandler(_bloc);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateSize());

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(MeasureAreaOld oldWidget) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateSize());
    super.didUpdateWidget(oldWidget);
  }

  void _updateSize() {
    RenderBox box = listenerKey.currentContext.findRenderObject();

    setState(() {
      viewSize = box.size;
      viewCenter = Offset(viewSize.width / 2, viewSize.height / 2);
    });

//    _bloc.viewWidth = viewSize.width;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
        key: listenerKey,
        onPointerDown: (PointerDownEvent event) {
          handler.registerDownEvent(event);
          logger.log("downEvent $event");

          setState(() {
            fingerPosition = event.localPosition;
            showMagnifyingGlass = true;
          });
        },
        onPointerMove: (PointerMoveEvent event) {
          handler.registerMoveEvent(event);
          logger.log("moveEvent $event}");

          setState(() {
            fingerPosition = event.localPosition;
          });
        },
        onPointerUp: (PointerUpEvent event) {
          handler.registerUpEvent(event);
          logger.log("upEvent $event");

          setState(() {
            showMagnifyingGlass = false;
            fingerPosition = event.localPosition;
          });
        },

        child: Stack(
          children: <Widget>[
//            _backgroundAndMeasurements(),
//            if (showMagnifyingGlass) _magnifyingGlass()
          ],
        )
    );
  }

  /*StreamBuilder<ui.Image> _magnifyingGlass() {
    return StreamBuilder(
      initialData: _bloc.backgroundImage,
      stream: _bloc.backgroundStream,
      builder: (BuildContext context, AsyncSnapshot<ui.Image> image) {
        if (image.hasData) {
          return _buildMagnifyingGlass(image);
        } else {
          return Opacity(opacity: 0.0,);
        }
      },
    );
  }

  StreamBuilder<bool> _backgroundAndMeasurements() {
    return StreamBuilder(
        initialData: _bloc.showDistance,
        stream: _bloc.showDistanceStream,
        builder: (BuildContext context, AsyncSnapshot<bool> showDistance) {
          logger.log("StreamBuilder: showDistance");

          return StreamBuilder(
              initialData: _bloc.distances,
              stream: _bloc.distancesStream,
              builder: (BuildContext context, AsyncSnapshot<List<double>> distanceSnapshot) {
                logger.log("StreamBuilder: distances");

                return StreamBuilder(
                    initialData: _bloc.points,
                    stream: _bloc.pointsStream,
                    builder: (BuildContext context, AsyncSnapshot<List<Offset>> points) {
                      // TODO check why points are update three times!
                      logger.log("StreamBuilder: points");
                      List<Widget> children = [widget.child];
                      children.addAll(_buildOverlays(points, showDistance, distanceSnapshot));

                      return Stack(children: children,);
                    });
              });
        });
  }*/

  List<Widget> _buildOverlays(AsyncSnapshot<List<Offset>> points, AsyncSnapshot<bool> showDistance, AsyncSnapshot<List<double>> distanceSnapshot) {
    List<Widget> painters = List();

    if (points.hasData && points.data.length >= 2) {
      List<Holder> holders = List();
      points.data.doInBetween((start, end) => holders.add(Holder(start, end)));

      if (_canDrawDistances(showDistance, distanceSnapshot)) {
        holders.zip(distanceSnapshot.data, (Holder holder, double distance) => holder.distance = distance);

        holders.forEach((Holder holder) {
          painters.add(_pointPainter(holder.start, holder.end));
          if (holder.distance != null) painters.add(_distancePainter(holder.start, holder.end, holder.distance));
        });

        logger.log("drawing with distance: $holders");
      } else {
        painters = holders
            .map((Holder holder) => _pointPainter(holder.start, holder.end))
            .toList();

        logger.log("drawing multiple points ${points.data}");
      }
    } else {
      Offset first, last;

      if (points.data.isNotEmpty) {
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

    return painters;
  }

  bool _canDrawDistances(AsyncSnapshot<bool> showDistance, AsyncSnapshot<List<double>> distanceSnapshot) =>
      showDistance.hasData && showDistance.data && distanceSnapshot.hasData && viewCenter != null;

  CustomPaint _distancePainter(Offset first, Offset last, double distance) {
    return CustomPaint(
      foregroundPainter: DistancePainter(
          start: first,
          end: last,
          distance: distance,
          viewCenter: viewCenter,
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

  Widget _buildMagnifyingGlass(AsyncSnapshot<ui.Image> image) {
    return CustomPaint(
      foregroundPainter: MagnifyingPainter(
          fingerPosition: fingerPosition,
          center: viewCenter,
          viewSize: viewSize,
          image: image.data,
          radius: magnificationRadius,
          imageScaleFactor: image.data.width / viewSize.width
      ),
    );
  }
}