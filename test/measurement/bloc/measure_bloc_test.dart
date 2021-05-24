/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:document_measure/src/input_bloc/input_bloc.dart';
import 'package:document_measure/src/input_bloc/input_state.dart';
import 'package:document_measure/src/measurement/bloc/magnification_bloc/magnification_bloc.dart';
import 'package:document_measure/src/measurement/bloc/magnification_bloc/magnification_event.dart';
import 'package:document_measure/src/measurement/bloc/magnification_bloc/magnification_state.dart';
import 'package:document_measure/src/measurement/repository/measurement_repository.dart';
import 'package:document_measure/src/metadata/repository/metadata_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../mocks/helpers.dart';
import '../../mocks/test_mocks.dart';

void main() {
  group('Measure Bloc Unit Test', () {
    final imageScaleFactor = 3.0;

    late MetadataRepository mockedMetadataRepository;
    late MeasurementRepository mockedMeasurementRepository;
    late InputBloc mockedInputBloc;

    setUpAll(() {
      registerStates();
    });

    setUp(() {
      mockedMetadataRepository = MockedMetadataRepository();
      mockedMeasurementRepository = MockedMeasurementRepository();
      mockedInputBloc = MockedInputBloc();

      when(() => mockedMetadataRepository.viewSize).thenAnswer((_) => Stream.fromIterable([Size(100, 200)]));
      when(() => mockedMetadataRepository.measurement).thenAnswer((_) => Stream.fromIterable([true]));
      when(() => mockedMetadataRepository.magnificationCircleRadius).thenAnswer((_) => Stream.fromIterable([10]));

      GetIt.I.registerSingleton(mockedMeasurementRepository);
      GetIt.I.registerSingleton(mockedMetadataRepository);

      whenListen(mockedInputBloc, Stream.fromIterable(<InputState>[]));
    });

    blocTest(
      'initial state',
      skip: 0,
      build: () {
        when(() => mockedMetadataRepository.backgroundImage).thenAnswer((_) => Stream.fromIterable([]));
        when(() => mockedMetadataRepository.imageScaleFactor).thenAnswer((_) => Stream.fromIterable([]));

        return MagnificationBloc(mockedInputBloc);
      },
      expect: () => [MagnificationInactiveState()],
    );

    group('UI events', () {
      blocTest(
        'stroke events',
        build: () {
          when(() => mockedMetadataRepository.backgroundImage).thenAnswer((_) => Stream.fromIterable([MockedImage.mock]));
          when(() => mockedMetadataRepository.imageScaleFactor).thenAnswer((_) => Stream.fromIterable([imageScaleFactor]));

          return MagnificationBloc(mockedInputBloc);
        },
        act: (MagnificationBloc bloc) async {
          bloc.add(MagnificationShowEvent(Offset(0, 0)));
          bloc.add(MagnificationShowEvent(Offset(10, 10)));
          bloc.add(MagnificationHideEvent());
        },
        expect: () => [
          MagnificationActiveState(Offset(0, 0), Offset(-10, -50), backgroundImage: MockedImage.mock, imageScaleFactor: imageScaleFactor),
          MagnificationActiveState(Offset(10, 10), Offset(0, -50), backgroundImage: MockedImage.mock, imageScaleFactor: imageScaleFactor),
          MagnificationInactiveState()
        ],
        verify: (_) async {
          verifyInOrder([
            () => mockedMeasurementRepository.convertIntoDocumentLocalTopLeftPosition(Offset(0, 0)),
            () => mockedMeasurementRepository.convertIntoDocumentLocalTopLeftPosition(Offset(10, 10)),
          ]);

          verifyNoMoreInteractions(mockedMeasurementRepository);
        },
      );
    });
  });
}
