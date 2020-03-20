import 'package:flutter/cupertino.dart';
import 'package:measurements/bloc/bloc_provider.dart';
import 'package:measurements/bloc/measurement_bloc.dart';
import 'package:measurements/overlay/measure_area.dart';
import 'package:measurements/util/Logger.dart';

class MeasurementView extends StatefulWidget {
  const MeasurementView({
    Key key,
    @required this.child,
    this.documentSize = const Size(210, 297),
    this.scale = 1.0,
    this.zoom = 1.0,
    this.measure = false,
    this.outputSink,
    this.measurePaintColor,
  });

  final Widget child;
  final Size documentSize;
  final double scale;
  final double zoom;
  final bool measure;
  final Color measurePaintColor;
  final Sink<double> outputSink;

  @override
  _MeasurementViewState createState() => _MeasurementViewState();
}

class _MeasurementViewState extends State<MeasurementView> {
  MeasurementBloc _bloc;

  @override
  void initState() {
    _bloc = MeasurementBloc(widget.documentSize, widget.outputSink);
    setWidgetArgumentsToBloc();

    super.initState();
  }

  @override
  void didUpdateWidget(MeasurementView oldWidget) {
    setWidgetArgumentsToBloc();

    super.didUpdateWidget(oldWidget);
  }

  void setWidgetArgumentsToBloc() {
    _bloc
      ..zoomLevel = widget.zoom
      ..scale = widget.scale;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        bloc: _bloc,
        child: _overlay()
    );
  }

  Widget _overlay() {
    if (widget.measure) {
      return MeasureArea(paintColor: widget.measurePaintColor, child: widget.child);
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
