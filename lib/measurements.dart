import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

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
    this.onViewCreated
  });

  final String filePath;
  final OnViewCreated onViewCreated;

  @override
  _MeasurementViewState createState() => _MeasurementViewState();
}

class _MeasurementViewState extends State<MeasurementView> {
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
