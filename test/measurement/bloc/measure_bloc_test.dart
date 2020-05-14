import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:measurements/measurement/bloc/measure_bloc/measure_bloc.dart';
import 'package:measurements/measurement/bloc/measure_bloc/measure_event.dart';
import 'package:measurements/measurement/bloc/measure_bloc/measure_state.dart';
import 'package:measurements/measurement/repository/measurement_repository.dart';
import 'package:measurements/metadata/repository/metadata_repository.dart';
import 'package:measurements/util/size.dart';
import 'package:mockito/mockito.dart';

class MockedMetadataRepository extends Mock implements MetadataRepository {}

class MockedMeasurementRepository extends Mock implements MeasurementRepository {}

class MockedImage extends Mock implements Image {
  static final _mockedImage = MockedImage._private();

  MockedImage._private();

  static MockedImage get mock => _mockedImage;
}

void main() {
  group("Measure Bloc Test", () {
    final imageScaleFactor = 3.0;

    MetadataRepository mockedMetadataRepository;
    MeasurementRepository mockedMeasurementRepository;

    setUp(() {
      mockedMetadataRepository = MockedMetadataRepository();
      mockedMeasurementRepository = MockedMeasurementRepository();

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
            MeasureActiveState(Offset(0, 0), backgroundImage: MockedImage.mock, imageScaleFactor: imageScaleFactor, magnificationRadius: magnificationRadius),
            MeasureActiveState(Offset(10, 10), backgroundImage: MockedImage.mock, imageScaleFactor: imageScaleFactor, magnificationRadius: magnificationRadius),
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