import 'package:flutter/cupertino.dart';
import 'package:measurements/bloc/bloc_provider.dart';
import 'package:measurements/bloc/measurement_bloc.dart';
import 'package:measurements/overlay/measure_area.dart';
import 'package:measurements/util/logger.dart';

class MeasurementView extends StatefulWidget {
  final Widget child;
  final Size documentSize;
  final double scale;
  final double zoom; //132: variables need to be above constructor
  final bool measure;
  final bool showDistanceOnLine;
  final Color measurePaintColor;
  final Function(List<double>, double) distanceCallback;

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

  @override
  _MeasurementViewState createState() => _MeasurementViewState();
}

class _MeasurementViewState extends State<MeasurementView> {
  Logger logger = Logger(LogDistricts.MEASUREMENT);
  MeasurementBloc _bloc;

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
    super.didUpdateWidget(oldWidget);
  }

// 132: this should be set with a function
  void _setWidgetArgumentsToBloc() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _bloc
      ..zoomLevel = widget.zoom
      ..scale = widget.scale
      ..showDistance = widget.showDistanceOnLine
      ..measuring = widget.measure);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        bloc: _bloc,
        child: OrientationBuilder(
          builder: (BuildContext context, Orientation orientation) {
            _bloc.orientation =
                orientation; //132: illegal. setting only by functions

            return _overlay();
          },
        ));
  }

  Widget _overlay() {
    if (widget.measure) {
      return MeasureArea(
          paintColor: widget.measurePaintColor, child: widget.child);
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
