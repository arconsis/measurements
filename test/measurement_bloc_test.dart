//import 'dart:async';
//
//import 'package:flutter/material.dart';
//import 'package:flutter_test/flutter_test.dart';
//
//void main() {
//  const zoomLevel = 1.0;
//  const scale = 1.0;
//
//  Function(List<double>) distanceCallback;
//  List<double> actualDistances = List();
//
//  MeasurementBlocOld classUnderTest;
//
//  TestWidgetsFlutterBinding.ensureInitialized();
//
//  setUpAll(() {
//    distanceCallback = (List<double> distances) {
//      actualDistances = distances;
//      print("Updated points $distances");
//    };
//  });
//
//  setUp(() {
//    classUnderTest = MeasurementBlocOld(Size(200, 300), distanceCallback);
//
//    classUnderTest.scale = scale;
//    classUnderTest.zoomLevel = zoomLevel;
//    classUnderTest.measuring = true;
//  });
//
//  tearDown(() {
//    classUnderTest.dispose();
//  });
//
//  test("getDistanceFromHorizontalPoints", () async {
//    Offset startPoint = Offset(10, 10);
//    Offset endPoint = Offset(110, 10);
//    List<double> expectedDistances = [50];
//
//    classUnderTest.._addPoint(startPoint).._addPoint(endPoint);
//
//    Timer(Duration(milliseconds: 500), () {
//      expect(actualDistances, expectedDistances);
//    });
//  });
//
//  test("getDistanceFromVerticalPoints", () async {
//    Offset startPoint = Offset(10, 10);
//    Offset endPoint = Offset(10, 110);
//    List<double> expectedDistances = [50];
//
//    classUnderTest.._addPoint(startPoint).._addPoint(endPoint);
//
//    Timer(Duration(milliseconds: 500), () {
//      expect(actualDistances, expectedDistances);
//    });
//  });
//}
