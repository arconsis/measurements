import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:measurements/bloc/measurement_bloc.dart';

void main() {
  const zoomLevel = 1.0;
  const scale = 1.0;
  const viewWidth = 400.0;
  const dpm = 20.0;

  const expectedZoomFactor = 10.0;
  const expectedDistance = 50;

  const MethodChannel channel = MethodChannel('measurements');

  StreamController<double> outputStreamController = StreamController<double>();

  MeasurementBloc classUnderTest = MeasurementBloc(Size(200, 300), outputStreamController.sink);

  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == "getPhysicalPixelsPerMM") {
        return dpm;
      } else {
        return -1;
      }
    });

    classUnderTest.viewWidth = viewWidth;
    classUnderTest.scale = scale;
    classUnderTest.zoomLevel = zoomLevel;

    outputStreamController.stream.listen((double distance) {
      expect(distance, expectedDistance);
    });
  });

  test("setZoomToOriginalSize", () async {
    double zoomFactor = await classUnderTest.getZoomFactorForOriginalSize();

    expect(zoomFactor, expectedZoomFactor);
  });

  test("getDistanceFromHorizontalPoints", () async {
    Offset startPoint = Offset(10, 10);
    Offset endPoint = Offset(110, 10);

    classUnderTest.fromPoint = startPoint;
    classUnderTest.toPoint = endPoint;
  });

  test("getDistanceFromVerticalPoints", () async {
    Offset startPoint = Offset(10, 10);
    Offset endPoint = Offset(10, 110);

    classUnderTest.fromPoint = startPoint;
    classUnderTest.toPoint = endPoint;
  });

  tearDownAll(() {
    classUnderTest.dispose();
    outputStreamController.close();

    channel.setMockMethodCallHandler(null);
  });
}
