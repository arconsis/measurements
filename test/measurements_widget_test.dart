/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:measure/measure.dart';
import 'package:measure/src/measurement/drawing_holder.dart';
import 'package:measure/src/measurement/overlay/measure_area.dart';
import 'package:measure/src/measurement/repository/measurement_repository.dart';
import 'package:measure/src/metadata/repository/metadata_repository.dart';

Type typeOf<T>() => T;

final imageWidth = 800.0;
final imageHeight = 600.0;
final imageWidget = Image.asset(
  "assets/images/example_portrait.png",
  package: "measure",
  width: imageWidth,
  height: imageHeight,
);

Widget fillTemplate(Widget measurement) {
  return MaterialApp(
    home: Scaffold(
      body: measurement,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final controller = MeasurementController();
  final measurementInformation = MeasurementInformation(documentWidthInLengthUnits: Millimeter(imageWidth * 2), documentHeightInLengthUnits: Millimeter(imageHeight * 2));

  group("Measurement Widget Integration Test", () {
    MetadataRepository metadataRepository;
    MeasurementRepository measurementRepository;

    setUp(() {
      metadataRepository = MetadataRepository();
      measurementRepository = MeasurementRepository(metadataRepository);

      GetIt.I.registerSingleton(metadataRepository);
      GetIt.I.registerSingleton(measurementRepository);
    });

    tearDown(() {
      GetIt.I.unregister(instance: metadataRepository);
      GetIt.I.unregister(instance: measurementRepository);
    });

    group("widget setup", () {
      testWidgets("measurement should show child also when measure is false", (WidgetTester tester) async {
        await tester.pumpWidget(fillTemplate(Measurements(
          child: imageWidget,
        )));

        expect(find.byType(typeOf<Image>()), findsOneWidget);
        expect(find.byType(typeOf<MeasureArea>()), findsOneWidget);
      });

      testWidgets("measurement should show child under measure area when measuring", (WidgetTester tester) async {
        await tester.pumpWidget(fillTemplate(Measurements(
          child: imageWidget,
          measure: true,
        )));

        await tester.pump();

        expect(find.byType(typeOf<Image>()), findsOneWidget);
        expect(find.byType(typeOf<MeasureArea>()), findsOneWidget);
      });
    });

    group("setting points", () {
      testWidgets("adding single point", (WidgetTester tester) async {
        await tester.pumpWidget(fillTemplate(Measurements(
          child: imageWidget,
          measure: true,
        )));

        await tester.pumpAndSettle();

        final gesture = await tester.startGesture(Offset(100, 100));
        await gesture.up();

        await tester.pumpAndSettle();

        measurementRepository.points.listen((actual) => expect(actual, [Offset(100, 100)]));
      });

      testWidgets("adding multiple points and getting distances", (WidgetTester tester) async {
        await tester.pumpWidget(fillTemplate(Measurements(
          child: imageWidget,
          measure: true,
          showDistanceOnLine: true,
          controller: controller,
          measurementInformation: measurementInformation,
        )));

        await tester.pumpAndSettle();

        final gesture = await tester.startGesture(Offset(100, 100));
        await gesture.up();

        await gesture.down(Offset(100, 300));
        await gesture.up();

        await gesture.down(Offset(300, 300));
        await gesture.up();

        await gesture.down(Offset(300, 100));
        await gesture.up();

        await tester.pumpAndSettle();

        final expectedDrawingHolder = DrawingHolder([Offset(100, 100), Offset(100, 300), Offset(300, 300), Offset(300, 100)], [Millimeter(400), Millimeter(400), Millimeter(400)]);

        measurementRepository.drawingHolder.listen((actual) => expect(actual, expectedDrawingHolder));
        expect(controller.distances, equals([400, 400, 400]));
        expect(controller.tolerance, equals(2));
      });

      testWidgets("add points without distances and then turn on distances", (WidgetTester tester) async {
        await tester.pumpWidget(fillTemplate(Measurements(
          child: imageWidget,
          measure: true,
          showDistanceOnLine: false,
          controller: controller,
          measurementInformation: measurementInformation,
        )));

        await tester.pumpAndSettle();

        final gesture = await tester.startGesture(Offset(100, 100));
        await gesture.up();

        await gesture.down(Offset(100, 300));
        await gesture.up();

        await gesture.down(Offset(300, 300));
        await gesture.up();

        await gesture.down(Offset(300, 100));
        await gesture.up();

        await tester.pumpAndSettle();

        measurementRepository.points.listen((actual) => expectSync(actual, [Offset(100, 100), Offset(100, 300), Offset(300, 300), Offset(300, 100)]));
        expect(controller.distances, equals([400, 400, 400]));
        expect(controller.tolerance, equals(2));

        await tester.pumpWidget(fillTemplate(Measurements(
          child: imageWidget,
          measure: true,
          showDistanceOnLine: true,
          measurementInformation: measurementInformation,
        )));

        await tester.pumpAndSettle();

        final expectedDrawingHolder = DrawingHolder([Offset(100, 100), Offset(100, 300), Offset(300, 300), Offset(300, 100)], [Millimeter(400), Millimeter(400), Millimeter(400)]);

        measurementRepository.drawingHolder.listen((actual) => expect(actual, expectedDrawingHolder));
        expect(controller.distances, equals([400, 400, 400]));
        expect(controller.tolerance, equals(2));
      });

      testWidgets("adding multiple points and getting distances with set scale", (WidgetTester tester) async {
        await tester.pumpWidget(fillTemplate(Measurements(
          child: imageWidget,
          measure: true,
          showDistanceOnLine: true,
          controller: controller,
          measurementInformation: MeasurementInformation(documentWidthInLengthUnits: Millimeter(imageWidth), documentHeightInLengthUnits: Millimeter(imageHeight), scale: 2.0),
        )));

        await tester.pumpAndSettle();

        final gesture = await tester.startGesture(Offset(100, 100));
        await gesture.up();

        await gesture.down(Offset(100, 300));
        await gesture.up();

        await gesture.down(Offset(300, 300));
        await gesture.up();

        await gesture.down(Offset(300, 100));
        await gesture.up();

        await tester.pumpAndSettle();

        final expectedDrawingHolder = DrawingHolder(
          [Offset(100, 100), Offset(100, 300), Offset(300, 300), Offset(300, 100)],
          [Millimeter(100), Millimeter(100), Millimeter(100)],
        );

        measurementRepository.drawingHolder.listen((actual) => expect(actual, expectedDrawingHolder));
        expect(controller.distances, equals([100, 100, 100]));
        expect(controller.tolerance, equals(0.5));
      });
    });

    group("controller interaction", () {
      final channel = MethodChannel("measurements");
      setUp(() {
        channel.setMockMethodCallHandler((call) async {
          if (call.method == "getPhysicalPixelsPerInch") {
            return 4.0;
          } else {
            return -1.0;
          }
        });
      });

      testWidgets("set zoom to original size and reset zoom level", (WidgetTester tester) async {
        await tester.pumpWidget(fillTemplate(Measurements(
          child: imageWidget,
          measure: true,
          showDistanceOnLine: true,
          controller: controller,
          measurementInformation: MeasurementInformation(documentWidthInLengthUnits: Inch(imageWidth), documentHeightInLengthUnits: Inch(imageHeight), scale: 2.0),
        )));

        await tester.pump();

        controller.zoomToLifeSize();
        await tester.pump();

        controller.resetZoom();
        await tester.pump();
      });
    });
  });
}
