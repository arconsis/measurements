import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:measurements/measurement/bloc/measure_bloc/measure_bloc.dart';
import 'package:measurements/measurement/bloc/measure_bloc/measure_event.dart';
import 'package:measurements/measurement/bloc/measure_bloc/measure_state.dart';
import 'package:measurements/measurement/repository/measurement_repository.dart';
import 'package:measurements/metadata/repository/metadata_repository.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/test_mocks.dart';

void main() {
  group("Measure Bloc Unit Test", () {
    final imageScaleFactor = 3.0;

    MetadataRepository mockedMetadataRepository;
    MeasurementRepository mockedMeasurementRepository;

    setUp(() {
      mockedMetadataRepository = MockedMetadataRepository();
      mockedMeasurementRepository = MockedMeasurementRepository();

      when(mockedMetadataRepository.viewSize).thenAnswer((_) => Stream.fromIterable([Size(100, 200)]));
      when(mockedMetadataRepository.magnificationCircleRadius).thenAnswer((_) => Stream.fromIterable([10]));

      GetIt.I.registerSingleton(mockedMeasurementRepository);
      GetIt.I.registerSingleton(mockedMetadataRepository);
    });

    tearDown(() {
      GetIt.I.unregister(instance: mockedMetadataRepository);
      GetIt.I.unregister(instance: mockedMeasurementRepository);
    });

    blocTest("initial state",
        skip: 0,
        build: () async {
          when(mockedMetadataRepository.backgroundImage).thenAnswer((_) => Stream.fromIterable([]));
          when(mockedMetadataRepository.imageScaleFactor).thenAnswer((_) => Stream.fromIterable([]));

          return MeasureBloc();
        },
        expect: [MeasureInactiveState()]
    );

    group("UI events", () {
      blocTest("stroke events",
          build: () async {
            when(mockedMetadataRepository.backgroundImage).thenAnswer((_) => Stream.fromIterable([MockedImage.mock]));
            when(mockedMetadataRepository.imageScaleFactor).thenAnswer((_) => Stream.fromIterable([imageScaleFactor]));

            return MeasureBloc();
          },
          act: (bloc) {
            bloc.add(MeasureDownEvent(Offset(0, 0)));
            bloc.add(MeasureMoveEvent(Offset(10, 10)));
            bloc.add(MeasureUpEvent(Offset(10, 10)));

            return;
          },
          expect: [
            MeasureActiveState(Offset(0, 0), Offset(-10, -50), backgroundImage: MockedImage.mock, imageScaleFactor: imageScaleFactor),
            MeasureActiveState(Offset(10, 10), Offset(0, -50), backgroundImage: MockedImage.mock, imageScaleFactor: imageScaleFactor),
            MeasureInactiveState()
          ],
          verify: (_) {
            verifyInOrder([
              mockedMeasurementRepository.registerDownEvent(Offset(0, 0)),
              mockedMeasurementRepository.registerMoveEvent(Offset(10, 10)),
              mockedMeasurementRepository.registerUpEvent(Offset(10, 10)),
            ]);

            verifyNoMoreInteractions(mockedMeasurementRepository);

            return;
          });
    });
  });
}
