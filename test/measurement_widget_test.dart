import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:measurements/measurements.dart';
import 'package:measurements/overlay/measure_area.dart';

Type typeOf<T>() => T;

final imageWidth = 800.0;
final imageHeight = 600.0;
final imageWidget = Image.asset(
  "assets/images/example_portrait.png",
  package: "measurements",
  width: imageWidth,
  height: imageHeight,
);

Future<void> createApp(WidgetTester tester, MeasurementView measurementView, {Matcher measurementMatcher = findsOneWidget, bool checkSizeOfMeasureArea = true}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: measurementView,
      ),
    ),
  );

  final imageFinder = find.byWidget(imageWidget);
  final measureFinder = find.byType(typeOf<MeasureArea>());

  expect(imageFinder, findsOneWidget);
  expect(measureFinder, measurementMatcher);

  checkWidgetHasCorrectSize(tester.getSize(imageFinder));

  if (checkSizeOfMeasureArea)
    checkWidgetHasCorrectSize(tester.getSize(measureFinder));
}

void checkWidgetHasCorrectSize(Size size) {
  expect(size.width, equals(imageWidth));
  expect(size.height, equals(imageHeight));
}

StreamController<List<double>> distanceController;
List<double> distances;

void main() {
  setUpAll(() {
    distanceController = StreamController<List<double>>();
    distances = List();

    distanceController.stream.listen((List<double> data) {
      distances = data;
    });
  });

  tearDownAll(() {
    distanceController?.close();
  });

  testWidgets("Measurement should show child without extras", (WidgetTester tester) async {
    final measurementView = MeasurementView(child: imageWidget);

    await createApp(tester, measurementView, measurementMatcher: findsNothing, checkSizeOfMeasureArea: false);
  });

  testWidgets("Measurement should show MeasureArea", (WidgetTester tester) async {
    final measurementView = MeasurementView(child: imageWidget, measure: true,);

    await createApp(tester, measurementView);

    final paintFinder = find.byType(typeOf<CustomPaint>());
    expect(paintFinder, findsOneWidget); // there seems to be a CustomPaint in the default widget tree
  });

  testWidgets("Measurement should show three Points", (WidgetTester tester) async {
    final List<double> expectedDistances = [80, 100];

    final measurementView = MeasurementView(
      child: imageWidget,
      documentSize: Size(imageWidth, imageHeight),
      measure: true,
      outputSink: distanceController.sink,
    );

    await createApp(tester, measurementView);

    final gesture = await tester.startGesture(Offset(10, 20));
    await gesture.up();

    await gesture.down(Offset(90, 20));
    await gesture.up();

    await gesture.down(Offset(90, 120));
    await gesture.up();

    await tester.pumpAndSettle();

    final paintFinder = find.byType(typeOf<CustomPaint>());

    expect(paintFinder, findsNWidgets(3));
    expect(distances, expectedDistances);
  });

  testWidgets("Measurement should show three points after moving one point", (WidgetTester tester) async {
    final List<double> expectedDistances = [80, 100];

    MeasurementView measurementView = MeasurementView(
      child: imageWidget,
      documentSize: Size(imageWidth, imageHeight),
      measure: true,
      outputSink: distanceController.sink,
    );

    await createApp(tester, measurementView);

    final gesture = await tester.startGesture(Offset(10, 20));
    await gesture.up();

    await gesture.down(Offset(90, 20));
    await gesture.up();

    await gesture.down(Offset(40, 150));
    await gesture.up();

    await tester.pumpAndSettle();

    Finder paintFinder = find.byType(typeOf<CustomPaint>());

    expect(paintFinder, findsNWidgets(3));
    expect(distances, isNot(expectedDistances));

    await gesture.down(Offset(45, 145));
    await gesture.moveTo(Offset(90, 120));
    await gesture.up();

    await tester.pumpAndSettle();

    expect(distances, expectedDistances);
  });

  testWidgets("Measurement should show four points after moving one point and setting another one at that position", (WidgetTester tester) async {
    final List<double> expectedDistances = [80, sqrt(100 * 100 + 200 * 200), sqrt(140 * 140 + 70 * 70)];

    MeasurementView measurementView = MeasurementView(
      child: imageWidget,
      documentSize: Size(imageWidth, imageHeight),
      measure: true,
      outputSink: distanceController.sink,
    );

    await createApp(tester, measurementView);

    final gesture = await tester.startGesture(Offset(10, 20));
    await gesture.up();

    await gesture.down(Offset(90, 20));
    await gesture.up();

    await gesture.down(Offset(40, 150));
    await gesture.up();

    await gesture.down(Offset(45, 145));
    await gesture.moveTo(Offset(190, 220));
    await gesture.up();

    await gesture.down(Offset(50, 150));
    await gesture.up();

    await tester.pumpAndSettle();

    Finder paintFinder = find.byType(typeOf<CustomPaint>());

    expect(paintFinder, findsNWidgets(4));
    expect(distances, expectedDistances);
  });

  testWidgets("Measurement should show distance with set scale and zoom", (WidgetTester tester) async {
    final List<double> expectedDistances = [80];

    final measurementView = MeasurementView(
      child: imageWidget,
      documentSize: Size(imageWidth, imageHeight),
      measure: true,
      outputSink: distanceController.sink,
      scale: 1 / 2.0,
      zoom: 2.0,
    );

    await createApp(tester, measurementView);

    final gesture = await tester.startGesture(Offset(10, 20));
    await gesture.up();

    await gesture.down(Offset(90, 20));
    await gesture.up();

    await tester.pumpAndSettle();

    final paintFinder = find.byType(typeOf<CustomPaint>());

    expect(paintFinder, findsNWidgets(2));
    expect(distances, expectedDistances);
  });
}