///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:measurements/measurement/drawing_holder.dart';
import 'package:measurements/measurement/repository/measurement_repository.dart';
import 'package:measurements/measurements.dart';
import 'package:measurements/metadata/repository/metadata_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';

import '../../mocks/test_mocks.dart';

void main() {
  group("Measurement Repository Unit Test", () {
    final transformationFactor = Millimeter(5.0);

    MetadataRepository metadataRepository;
    MeasurementRepository measurementRepository;
    BehaviorSubject<LengthUnit> transformationFactorController;
    MeasurementController controller;

    setUp(() {
      metadataRepository = MockedMetadataRepository();

      transformationFactorController = BehaviorSubject.seeded(transformationFactor);

      controller = MeasurementController();

      when(metadataRepository.transformationFactor).thenAnswer((_) => transformationFactorController.stream);
      when(metadataRepository.controller).thenAnswer((_) => Stream.fromIterable([controller]));
      when(metadataRepository.zoom).thenAnswer((_) => Stream.fromIterable([1.0]));
      when(metadataRepository.viewCenter).thenAnswer((_) => Stream.fromIterable([]));
      when(metadataRepository.backgroundPosition).thenAnswer((_) => Stream.fromIterable([Offset(0, 0)]));

      measurementRepository = MeasurementRepository(metadataRepository);
    });

    tearDown(() {
      transformationFactorController.close();
    });

    group("single events", () {
      test("down event", () {
        final expectedPoints = [Offset(10, 10)];

        measurementRepository.registerDownEvent(Offset(10, 10));

        measurementRepository.points.listen((actual) => expect(actual, expectedPoints));
      });

      test("starting with move event should not work", () {
        final expectedPoints = [];

        measurementRepository.registerMoveEvent(Offset(10, 10));

        measurementRepository.points.listen((actual) => expect(actual, expectedPoints));
      });

      test("starting with up event should not work", () {
        final expectedPoints = [];

        measurementRepository.registerUpEvent(Offset(10, 10));

        measurementRepository.points.listen((actual) => expect(actual, expectedPoints));
      });
    });

    group("multiple events", () {
      test("update same point", () {
        final expectedPoints = [Offset(15, 15)];

        measurementRepository.registerDownEvent(Offset(10, 10));
        measurementRepository.registerUpEvent(Offset(10, 10));
        measurementRepository.registerDownEvent(Offset(15, 15));
        measurementRepository.registerUpEvent(Offset(15, 15));

        measurementRepository.points.listen((actual) => expect(actual, expectedPoints));
      });

      test("update same point without releasing", () {
        final expectedPoints = [Offset(10, 10)];

        measurementRepository.registerDownEvent(Offset(10, 10));
        measurementRepository.registerDownEvent(Offset(15, 15));

        measurementRepository.points.listen((actual) => expect(actual, expectedPoints));
      });

      test("move first point, set second point", () {
        final expectedPoints = [Offset(10, 10), Offset(110, 10)];

        measurementRepository.registerDownEvent(Offset(15, 15));
        measurementRepository.registerMoveEvent(Offset(10, 5));
        measurementRepository.registerMoveEvent(Offset(5, 10));
        measurementRepository.registerUpEvent(Offset(10, 10));

        measurementRepository.registerDownEvent(Offset(110, 10));
        measurementRepository.registerUpEvent(Offset(110, 10));

        measurementRepository.points.listen((actual) => expect(actual, expectedPoints));
        expect(controller.distances, [100 * transformationFactor.value]);
      });

      test("two points with distance", () {
        final expectedHolder = DrawingHolder([Offset(0, 100), Offset(100, 100)], [transformationFactor * 100]);

        measurementRepository.registerDownEvent(Offset(0, 100));
        measurementRepository.registerUpEvent(Offset(0, 100));

        measurementRepository.registerDownEvent(Offset(100, 100));
        measurementRepository.registerUpEvent(Offset(100, 100));

        measurementRepository.drawingHolder.listen((actual) => expect(actual, expectedHolder));
        expect(controller.distances, [100 * transformationFactor.value]);
      });

      test("two points, holding second should have null distance", () {
        final expectedHolder = DrawingHolder([Offset(0, 100), Offset(100, 100)], [null]);

        measurementRepository.registerDownEvent(Offset(0, 100));
        measurementRepository.registerUpEvent(Offset(0, 100));

        measurementRepository.registerDownEvent(Offset(100, 100));
        measurementRepository.registerUpEvent(Offset(100, 100));
        measurementRepository.registerDownEvent(Offset(100, 100));


        measurementRepository.drawingHolder.listen((actual) => expect(actual, expectedHolder));
        expect(controller.distances, [100 * transformationFactor.value]);
      });

      test("set five points with distances", () {
        final expectedHolder = DrawingHolder(
            [
              Offset(0, 100),
              Offset(100, 100),
              Offset(100, 200),
              Offset(200, 200),
              Offset(300, 200),
            ],
            [
              transformationFactor * 100,
              transformationFactor * 100,
              transformationFactor * 100,
              transformationFactor * 100,
            ]);

        measurementRepository.registerDownEvent(Offset(0, 100));
        measurementRepository.registerUpEvent(Offset(0, 100));

        measurementRepository.registerDownEvent(Offset(100, 100));
        measurementRepository.registerUpEvent(Offset(100, 100));

        measurementRepository.registerDownEvent(Offset(100, 200));
        measurementRepository.registerUpEvent(Offset(100, 200));

        measurementRepository.registerDownEvent(Offset(200, 200));
        measurementRepository.registerUpEvent(Offset(200, 200));

        measurementRepository.registerDownEvent(Offset(300, 200));
        measurementRepository.registerUpEvent(Offset(300, 200));

        measurementRepository.drawingHolder.listen((actual) => expect(actual, expectedHolder));
        expect(controller.distances, [
          100 * transformationFactor.value,
          100 * transformationFactor.value,
          100 * transformationFactor.value,
          100 * transformationFactor.value,
        ]);
      });

      test("update transformation factor changes distances", () async {
        final expectedHolder = DrawingHolder([Offset(0, 100), Offset(100, 100)], [transformationFactor * 100]);
        final expectedUpdatedHolder = DrawingHolder([Offset(0, 100), Offset(100, 100)], [transformationFactor * 2 * 100]);

        measurementRepository.registerDownEvent(Offset(0, 100));
        measurementRepository.registerUpEvent(Offset(0, 100));

        measurementRepository.registerDownEvent(Offset(100, 100));
        measurementRepository.registerUpEvent(Offset(100, 100));

        StreamSubscription sub;
        sub = measurementRepository.drawingHolder.listen((actual) {
          expect(actual, expectedHolder);
          sub?.cancel();
        });
        expect(controller.distances, [100 * transformationFactor.value]);

        transformationFactorController.add(transformationFactor * 2);

        await Future.delayed(Duration(microseconds: 1));

        measurementRepository.drawingHolder.listen((actual) => expect(actual, expectedUpdatedHolder));
        expect(controller.distances, [100 * transformationFactor.value * 2]);
      });
    });
  });
}