///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:measurements/measurement/drawing_holder.dart';
import 'package:measurements/measurement/repository/measurement_repository.dart';
import 'package:measurements/measurements.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';

import '../../metadata/bloc/metadata_bloc_test.dart';

void main() {
  group("Measurement Repository Unit Test", () {
    final transformationFactor = Millimeter(5.0);

    MockMetadataRepository metadataRepository;
    MeasurementRepository measurementRepository;
    BehaviorSubject<LengthUnit> transformationFactorController;

    setUp(() {
      metadataRepository = MockMetadataRepository();

      transformationFactorController = BehaviorSubject.seeded(transformationFactor);

      when(metadataRepository.viewScaleFactor).thenAnswer((_) => Stream.fromIterable([]));
      when(metadataRepository.transformationFactor).thenAnswer((_) => transformationFactorController.stream);
      when(metadataRepository.callback).thenAnswer((_) => Stream.fromIterable([]));

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
        measurementRepository.registerDownEvent(Offset(10, 5));
        measurementRepository.registerDownEvent(Offset(5, 10));
        measurementRepository.registerDownEvent(Offset(15, 15));

        measurementRepository.points.listen((actual) => expect(actual, expectedPoints));
      });

      test("move first point, set second point", () {
        final expectedPoints = [Offset(15, 15), Offset(100, 100)];

        measurementRepository.registerDownEvent(Offset(10, 10));
        measurementRepository.registerMoveEvent(Offset(10, 5));
        measurementRepository.registerMoveEvent(Offset(5, 10));
        measurementRepository.registerUpEvent(Offset(15, 15));

        measurementRepository.registerDownEvent(Offset(100, 100));

        measurementRepository.points.listen((actual) => expect(actual, expectedPoints));
      });

      test("two points with distance", () {
        final expectedHolder = DrawingHolder([Offset(0, 100), Offset(100, 100)], [transformationFactor * 100]);

        measurementRepository.registerDownEvent(Offset(0, 100));
        measurementRepository.registerUpEvent(Offset(0, 100));

        measurementRepository.registerDownEvent(Offset(100, 100));
        measurementRepository.registerUpEvent(Offset(100, 100));

        measurementRepository.drawingHolder.listen((actual) => expect(actual, expectedHolder));
      });

      test("two points, holding second should have null distance", () {
        final expectedHolder = DrawingHolder([Offset(0, 100), Offset(100, 100)], [null]);

        measurementRepository.registerDownEvent(Offset(0, 100));
        measurementRepository.registerUpEvent(Offset(0, 100));

        measurementRepository.registerDownEvent(Offset(100, 100));
        measurementRepository.registerUpEvent(Offset(100, 100));
        measurementRepository.registerDownEvent(Offset(100, 100));


        measurementRepository.drawingHolder.listen((actual) => expect(actual, expectedHolder));
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

        transformationFactorController.add(transformationFactor * 2);

        await Future.delayed(Duration(microseconds: 1));

        measurementRepository.drawingHolder.listen((actual) => expect(actual, expectedUpdatedHolder));
      });
    });
  });
}