import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:measurements/bloc/bloc_provider.dart';
import 'package:measurements/measure_area.dart';
import 'package:measurements/measurement_bloc.dart';
import 'package:measurements/pdf_view.dart';

typedef OnViewCreated(int id);

//class Measurements {
//  static const MethodChannel _channel =
//  const MethodChannel('measurements');
//
//  static Future<String> get platformVersion async {
//    final String version = await _channel.invokeMethod('getPlatformVersion');
//    return version;
//  }
//}

class MeasurementView extends StatefulWidget {
  const MeasurementView({
    Key key,
    this.filePath,
    this.onViewCreated,
    this.scale,
    this.outputStream,
    this.measure,
  });

  final String filePath;
  final OnViewCreated onViewCreated;
  final double scale;
  final StreamSink<double> outputStream;
  final bool measure;


  @override
  _MeasurementViewState createState() => _MeasurementViewState();
}

class _MeasurementViewState extends State<MeasurementView> {
  MeasurementBloc _bloc;

  @override
  void initState() {
    _bloc = MeasurementBloc();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: _bloc,
      child: Stack(
        children: <Widget>[
          PdfView(filePath: widget.filePath, onViewCreated: widget.onViewCreated),
          if (widget.measure)
            MeasureArea()
          else
            Opacity(opacity: 0.0),

        ],
      )
      ,
    );
  }
}
