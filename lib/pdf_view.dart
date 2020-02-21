import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

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

  @override
  Widget build(BuildContext context) {
    print("Build MeasurementView");

    if (Platform.isAndroid) {
      print("MEASUREMENT: AndroidView with path: ${widget.filePath}");

      return AndroidView(
          viewType: "measurement_view",
          creationParams: <String, dynamic>{
            "filePath": widget.filePath,
          },
          creationParamsCodec: StandardMessageCodec(),
          onPlatformViewCreated: widget.onViewCreated
      );
    }

    return Text("${Platform.operatingSystem} is not supported yet");
  }

}