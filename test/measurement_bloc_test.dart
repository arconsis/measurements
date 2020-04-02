import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:measurements/bloc/measurement_bloc.dart';

void main() {
  const zoomLevel = 1.0;
  const scale = 1.0;
  const viewWidth = 400.0;
  const dpm = 20.0;

  const expectedZoomFactor = 10.0;

  const MethodChannel channel = MethodChannel('measurements');

  StreamController<List<double>> outputStreamController = StreamController();
  List<double> actualDistances = List();

  MeasurementBloc classUnderTest;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == "getPhysicalPixelsPerMM") {
        return dpm;
      } else {
        return -1;
      }
    });

    outputStreamController.stream.listen((List<double> distances) {
      actualDistances = distances;
      print("Updated points $distances");
    });
  });

  setUp(() {
    classUnderTest = MeasurementBloc(Size(200, 300), outputStreamController.sink);

    classUnderTest.viewWidth = viewWidth;
    classUnderTest.scale = scale;
    classUnderTest.zoomLevel = zoomLevel;
    classUnderTest.measuring = true;
  });

  tearDown(() {
    classUnderTest.dispose();
  });

  tearDownAll(() {
    outputStreamController.close();

    channel.setMockMethodCallHandler(null);
  });

  test("setZoomToOriginalSize", () async {
    double zoomFactor = await classUnderTest.getZoomFactorForOriginalSize();

    expect(zoomFactor, expectedZoomFactor);
  });

  test("getDistanceFromHorizontalPoints", () async {
    Offset startPoint = Offset(10, 10);
    Offset endPoint = Offset(110, 10);
    List<double> expectedDistances = [50];

    classUnderTest..addPoint(startPoint)..addPoint(endPoint);

    Timer(Duration(milliseconds: 500), () {
      expect(actualDistances, expectedDistances);
    });
  });

  test("getDistanceFromVerticalPoints", () async {
    Offset startPoint = Offset(10, 10);
    Offset endPoint = Offset(10, 110);
    List<double> expectedDistances = [50];

    classUnderTest..addPoint(startPoint)..addPoint(endPoint);

    Timer(Duration(milliseconds: 500), () {
      expect(actualDistances, expectedDistances);
    });
  });
}
