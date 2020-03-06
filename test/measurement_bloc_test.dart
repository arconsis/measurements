import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:measurements/bloc/measurement_bloc.dart';
import 'package:measurements/overlay/point.dart';

void main() {
  const int id = 3;
  const zoomLevel = 2;
  const deviceWidth = 400 / 25.4;
  const deviceHeight = 800 / 25.4;
  const expectedDistance = 200;

  const MethodChannel channel = MethodChannel('measurements');
  const MethodChannel setZoomChannel = MethodChannel("measurement_pdf_set_zoom_$id");
  const EventChannel getZoomChannel = EventChannel("measurement_pdf_zoom_$id");

  StreamController<double> outputStreamController = StreamController<double>();

  MeasurementBloc classUnderTest = MeasurementBloc(1 / 4.0, Size(200, 300), outputStreamController.sink);

  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == "getPhysicalScreenSize") {
        Map result = Map();

        result["width"] = deviceWidth;
        result["height"] = deviceHeight;

        return result;
      }

      return Map();
    });

    setZoomChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == "setZoom") {
        double zoomLevelArg = methodCall.arguments;

        expect(zoomLevelArg, zoomLevel);
      }
    });

    classUnderTest.viewWidth.add(400);
    classUnderTest.viewId.add(id);

    outputStreamController.stream.listen((double distance) {
      expect(distance, expectedDistance);
    });
  });

  test("setZoomToOriginalSize", () async {
    classUnderTest.zoomToOriginal();
  });

  test("getDistanceFromHorizontalPoints", () async {
    Point startPoint = Point(Offset(10, 10));
    Point endPoint = Point(Offset(110, 10));

    classUnderTest.fromPoint.add(startPoint);
    classUnderTest.toPoint.add(endPoint);
  });

  test("getDistanceFromVerticalPoints", () async {
    Point startPoint = Point(Offset(10, 10));
    Point endPoint = Point(Offset(10, 110));

    classUnderTest.fromPoint.add(startPoint);
    classUnderTest.toPoint.add(endPoint);
  });

  tearDownAll(() {
    classUnderTest.dispose();
    outputStreamController.close();

    channel.setMockMethodCallHandler(null);
    setZoomChannel.setMockMethodCallHandler(null);
  });
}
