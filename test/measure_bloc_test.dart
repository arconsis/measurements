import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:measurements/measurement/bloc/measure_bloc/measure_bloc.dart';

void main() {
  const zoomLevel = 1.0;
  const scale = 1.0;

  Function(List<double>) distanceCallback;
  List<double> actualDistances = List();

  MeasureBloc measureBloc;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    distanceCallback = (List<double> distances) {
      actualDistances = distances;
      print("Updated points $distances");
    };
  });

  setUp(() => measureBloc = MeasureBloc());

  tearDown(() => measureBloc?.close());

  test("getDistanceFromHorizontalPoints", () async {
    measureBloc.

    Offset startPoint = Offset(10, 10);
    Offset endPoint = Offset(110, 10);
    List<double> expectedDistances = [50];

    Timer(Duration(milliseconds: 500), () {
      expect(actualDistances, expectedDistances);
    });
  });

  test("getDistanceFromVerticalPoints", () async {
    Offset startPoint = Offset(10, 10);
    Offset endPoint = Offset(10, 110);
    List<double> expectedDistances = [50];

    measureBloc.._addPoint(startPoint).._addPoint(endPoint);

    Timer(Duration(milliseconds: 500), () {
      expect(actualDistances, expectedDistances);
    });
  });
}
