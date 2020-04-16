import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:measurements/bloc/bloc_provider.dart';
import 'package:measurements/bloc/measurement_bloc.dart';
import 'package:measurements/overlay/measure_area.dart';
import 'package:measurements/util/logger.dart';

class MeasurementView extends StatefulWidget {
  const MeasurementView({
    Key key,
    @required this.child,
    this.documentSize = const Size(210, 297),
    this.scale = 1.0,
    this.zoom = 1.0,
    this.measure = false,
    this.showDistanceOnLine = false,
    this.distanceCallback,
    this.measurePaintColor,
  });

  final Widget child;
  final Size documentSize;
  final double scale;
  final double zoom;
  final bool measure;
  final bool showDistanceOnLine;
  final Color measurePaintColor;
  final Function(List<double>) distanceCallback;

  @override
  _MeasurementViewState createState() => _MeasurementViewState();
}

class _MeasurementViewState extends State<MeasurementView> {
  Logger logger = Logger(LogDistricts.MEASUREMENT);
  MeasurementBloc _bloc;
  GlobalKey childKey = GlobalKey();

  @override
  void didChangeDependencies() {
    logger.log("didChangeDependencies");

    _bloc = MeasurementBloc(widget.documentSize, widget.distanceCallback);
    _setWidgetArgumentsToBloc();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(MeasurementView oldWidget) {
    logger.log("didUpdateWidget");

    _setWidgetArgumentsToBloc();
    _setBackgroundImageToBloc();
    super.didUpdateWidget(oldWidget);
  }

  void _setWidgetArgumentsToBloc() {
    WidgetsBinding.instance.addPostFrameCallback((_) =>
    _bloc
      ..zoomLevel = widget.zoom
      ..scale = widget.scale
      ..showDistance = widget.showDistanceOnLine
      ..measuring = widget.measure
    );
  }

  void _setBackgroundImageToBloc() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.measure) {
        RenderRepaintBoundary boundary = childKey.currentContext.findRenderObject();
        _bloc.backgroundImage = await boundary.toImage(pixelRatio: 4.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        bloc: _bloc,
        child: OrientationBuilder(builder: (BuildContext context, Orientation orientation) {
          _bloc.orientation = orientation;

          return _overlay();
        },)
    );
  }

  Widget _overlay() {
    if (widget.measure) {
      return MeasureArea(
        paintColor: widget.measurePaintColor,
        child: RepaintBoundary(
          key: childKey,
          child: widget.child,),
      );
    } else {
      return widget.child;
    }
  }

  @override
  void dispose() {
    _bloc?.dispose();
    super.dispose();
  }
}
