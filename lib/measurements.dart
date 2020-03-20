import 'package:flutter/cupertino.dart';
import 'package:measurements/bloc/bloc_provider.dart';
import 'package:measurements/bloc/measurement_bloc.dart';
import 'package:measurements/overlay/measure_area.dart';

class MeasurementView extends StatefulWidget {
  const MeasurementView({
    Key key,
    @required this.child,
    this.documentSize = const Size(210, 297),
    this.scale = 1.0,
    this.zoom = 1.0,
    this.measure = false,
    this.showOriginalSize = false,
    this.outputSink,
    this.measurePaintColor,
  });

  final Widget child;
  final Size documentSize;
  final double scale;
  final double zoom;
  final bool measure;
  final bool showOriginalSize;
  final Color measurePaintColor;
  final Sink<double> outputSink;

  @override
  _MeasurementViewState createState() => _MeasurementViewState();
}

class _MeasurementViewState extends State<MeasurementView> {
  MeasurementBloc _bloc;

  bool showOriginalSizeLastState = false;

  @override
  void initState() {
    _bloc = MeasurementBloc(widget.scale, widget.documentSize, widget.outputSink);

    super.initState();
  }

  @override
  void didUpdateWidget(MeasurementView oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  void zoomIfWidgetParamChanged() {
    if (widget.showOriginalSize && widget.showOriginalSize != showOriginalSizeLastState) {
      _bloc.zoomToOriginal();
    }

    showOriginalSizeLastState = widget.showOriginalSize;
  }

  @override
  Widget build(BuildContext context) {
    zoomIfWidgetParamChanged();

    return BlocProvider(
      bloc: _bloc,
      child: Stack(
        children: <Widget>[
          widget.child,
          if (widget.measure) MeasureArea(paintColor: widget.measurePaintColor),
        ],
      )
      ,
    );
  }

  Widget _overlay() {
    if (widget.measure)
      return MeasureArea(paintColor: widget.measurePaintColor);

    return null;
  }

  @override
  void dispose() {
    _bloc?.dispose();
    super.dispose();
  }
}
