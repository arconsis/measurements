/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
import 'dart:math';

import 'package:bloc_test/bloc_test.dart';
import 'package:document_measure/document_measure.dart';
import 'package:document_measure/src/measurement/bloc/points_bloc/points_bloc.dart';
import 'package:document_measure/src/measurement/bloc/points_bloc/points_state.dart';
import 'package:document_measure/src/measurement/drawing_holder.dart';
import 'package:document_measure/src/measurement/overlay/holder.dart';
import 'package:document_measure/src/measurement/repository/measurement_repository.dart';
import 'package:document_measure/src/metadata/repository/metadata_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../mocks/test_mocks.dart';

void main() {
  group('Points Bloc Unit Test', () {
    late MeasurementRepository measurementRepository;
    late MetadataRepository metadataRepository;

    setUp(() {
      measurementRepository = MockedMeasurementRepository();
      metadataRepository = MockedMetadataRepository();

      when(() => metadataRepository.tolerance).thenAnswer((_) => Stream.fromIterable([0.0]));
      when(() => metadataRepository.unitOfMeasurement).thenAnswer((_) => Stream.fromIterable([Millimeter.asUnit()]));

      GetIt.I.registerSingleton(measurementRepository);
      GetIt.I.registerSingleton(metadataRepository);
    });

    tearDown(() {
      GetIt.I.unregister(instance: measurementRepository);
      GetIt.I.unregister(instance: metadataRepository);
    });

    blocTest(
      'initial state',
      build: () {
        when(() => metadataRepository.showDistances).thenAnswer((_) => Stream.fromIterable([]));
        when(() => metadataRepository.viewCenter).thenAnswer((_) => Stream.fromIterable([]));

        return PointsBloc();
      },
      skip: 0,
      expect: () => [
        PointsEmptyState(),
      ],
    );

    group('UI events', () {
      blocTest(
        'no points',
        build: () {
          when(() => metadataRepository.showDistances).thenAnswer((_) => Stream.fromIterable([false]));
          when(() => metadataRepository.viewCenter).thenAnswer((_) => Stream.fromIterable([]));

          when(() => measurementRepository.points).thenAnswer((_) => Stream.fromIterable([
                [Offset(10, 10)],
                [],
              ]));

          return PointsBloc();
        },
        wait: Duration(microseconds: 1),
        skip: 2,
        expect: () => [
          PointsEmptyState(),
        ],
      );

      blocTest(
        'single point',
        build: () {
          when(() => metadataRepository.showDistances).thenAnswer((_) => Stream.fromIterable([false]));
          when(() => metadataRepository.viewCenter).thenAnswer((_) => Stream.fromIterable([]));

          when(() => measurementRepository.points).thenAnswer((_) => Stream.fromIterable([
                [Offset(10, 10)]
              ]));

          return PointsBloc();
        },
        expect: () => [
          PointsSingleState(Offset(10, 10)),
        ],
      );

      blocTest(
        'two points without distance',
        build: () {
          when(() => metadataRepository.showDistances).thenAnswer((_) => Stream.fromIterable([false]));
          when(() => metadataRepository.viewCenter).thenAnswer((_) => Stream.fromIterable([]));

          when(() => measurementRepository.points).thenAnswer((_) => Stream.fromIterable([
                [Offset(10, 10), Offset(20, 20)]
              ]));

          return PointsBloc();
        },
        expect: () => [
          PointsOnlyState([Offset(10, 10), Offset(20, 20)])
        ],
      );

      blocTest(
        'two points with distance',
        build: () {
          when(() => metadataRepository.showDistances).thenAnswer((_) => Stream.fromIterable([true]));
          when(() => metadataRepository.viewCenter).thenAnswer((_) => Stream.fromIterable([Offset(0, 0)]));

          when(() => measurementRepository.drawingHolder).thenAnswer((_) => Stream.fromIterable([
                DrawingHolder([Offset(10, 10), Offset(20, 20)], [Millimeter(sqrt(200))])
              ]));

          return PointsBloc();
        },
        expect: () => [
          PointsAndDistanceState([Holder.withDistance(Offset(10, 10), Offset(20, 20), Millimeter(sqrt(200)))], Offset(0, 0), 0.0)
        ],
      );

      blocTest(
        'active measurement with two points and distances',
        build: () {
          when(() => metadataRepository.showDistances).thenAnswer((_) => Stream.fromIterable([true]));
          when(() => metadataRepository.viewCenter).thenAnswer((_) => Stream.fromIterable([Offset(0, 0)]));

          when(() => measurementRepository.drawingHolder).thenAnswer((_) => Stream.fromIterable([
                DrawingHolder([Offset(10, 10), Offset(20, 20)], [null])
              ]));

          return PointsBloc();
        },
        expect: () => [
          PointsAndDistanceActiveState([Holder.withDistance(Offset(10, 10), Offset(20, 20), null)], Offset(0, 0), 0.0, [0, 0]),
        ],
      );

      blocTest(
        'active measurement on second last point with five points and distances',
        build: () {
          when(() => metadataRepository.showDistances).thenAnswer((_) => Stream.fromIterable([true]));
          when(() => metadataRepository.viewCenter).thenAnswer((_) => Stream.fromIterable([Offset(0, 0)]));

          when(() => measurementRepository.drawingHolder).thenAnswer((_) => Stream.fromIterable([
                DrawingHolder(
                    [Offset(10, 10), Offset(20, 20), Offset(20, 30), Offset(30, 30), Offset(10, 30)], [Millimeter(sqrt(200)), Millimeter(10), null, null])
              ]));

          return PointsBloc();
        },
        expect: () => [
          PointsAndDistanceActiveState(
            [
              Holder.withDistance(Offset(10, 10), Offset(20, 20), Millimeter(sqrt(200))),
              Holder.withDistance(Offset(20, 20), Offset(20, 30), Millimeter(10)),
              Holder.withDistance(Offset(20, 30), Offset(30, 30), null),
              Holder.withDistance(Offset(30, 30), Offset(10, 30), null)
            ],
            Offset(0, 0),
            0.0,
            [2, 3],
          ),
        ],
      );
    });
  });
}
