import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:measurements/bloc/bloc_provider.dart';
import 'package:measurements/measurement_bloc.dart';

typedef OnViewCreated(int id);

class PdfView extends StatefulWidget {
  const PdfView({
    Key key,
    this.filePath,
    this.onViewCreated,
  });

  final String filePath;
  final OnViewCreated onViewCreated;

  @override
  State<StatefulWidget> createState() => _PdfViewState();

}

class _PdfViewState extends State<PdfView> {
  MeasurementBloc _bloc;

  @override
  void initState() {
    _bloc = BlocProvider.of(context);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return AndroidView(
          viewType: "measurement_view",
          creationParams: <String, dynamic>{
            "filePath": widget.filePath,
          },
          creationParamsCodec: StandardMessageCodec(),
          onPlatformViewCreated: widget.onViewCreated,
      );
    }

    return Text("${Platform.operatingSystem} is not supported yet");
  }

}