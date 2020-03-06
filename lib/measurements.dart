import 'package:flutter/cupertino.dart';
import 'package:measurements/bloc/bloc_provider.dart';
import 'package:measurements/overlay/measure_area.dart';
import 'package:measurements/bloc/measurement_bloc.dart';
import 'package:measurements/pdf_view.dart';

typedef OnViewCreated(int id);

class MeasurementView extends StatefulWidget {
  const MeasurementView({
    Key key,
    this.filePath,
    this.documentSize = const Size(210, 297),
    this.scale = 1.0,
    this.measure = false,
    this.showOriginalSize = false,
    this.onViewCreated,
    this.outputSink,
    this.measurePaintColor,
  });

  final String filePath;
  final Size documentSize;
  final double scale;
  final OnViewCreated onViewCreated;
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
          _showPdf(),
          _overlay(),
        ],
      ),
    );
  }

  Widget _showPdf() {
    return PdfView(filePath: widget.filePath, onViewCreated: widget.onViewCreated);
  }

  Widget _overlay() {
    if (widget.measure)
      return MeasureArea(paintColor: widget.measurePaintColor);
    else
      return Opacity(opacity: 0.0);
  }

  @override
  void dispose() {
    _bloc?.dispose();
    super.dispose();
  }
}
