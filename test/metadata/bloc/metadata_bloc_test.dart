/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:document_measure/document_measure.dart';
import 'package:document_measure/src/metadata/bloc/metadata_bloc.dart';
import 'package:document_measure/src/metadata/bloc/metadata_event.dart';
import 'package:document_measure/src/metadata/bloc/metadata_state.dart';
import 'package:document_measure/src/metadata/repository/metadata_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';

import '../../mocks/test_mocks.dart';

void main() {
  group('Metadata Bloc Unit Test', () {
    MetadataRepository mockedRepository;
    BehaviorSubject<bool> measurement;
    Image mockedImage;

    final measurementInformation = MeasurementInformation.dinA4(scale: 1.0);
    final measure = true;
    final showDistance = true;
    final magnificationStyle = MagnificationStyle();
    final measurementController = MeasurementController();

    final startedEvent = MetadataStartedEvent(
      measurementInformation: measurementInformation,
      measure: measure,
      showDistances: showDistance,
      magnificationStyle: magnificationStyle,
      controller: measurementController,
    );

    setUp(() {
      mockedImage = MockedImage.mock;
      measurement = BehaviorSubject();
      mockedRepository = MockedMetadataRepository();
      GetIt.I.registerSingleton(mockedRepository);
    });

    tearDown(() {
      GetIt.I.unregister(instance: mockedRepository);
      measurement?.close();
    });

    blocTest(
      'initial state',
      skip: 0,
      build: () async => MetadataBloc(),
      expect: [MetadataState()],
    );

    group('metadata events', () {
      blocTest(
        'started event',
        build: () async => MetadataBloc(),
        act: (bloc) => bloc.add(startedEvent),
        verify: (MetadataBloc bloc) async {
          verify(mockedRepository.registerStartupValuesChange(
            measurementInformation: measurementInformation,
            measure: measure,
            showDistance: showDistance,
            magnificationStyle: magnificationStyle,
            controller: measurementController,
          )).called(1);
        },
      );

      blocTest(
        'background event',
        skip: 0,
        build: () async => MetadataBloc(),
        act: (bloc) =>
            bloc.add(MetadataBackgroundEvent(mockedImage, Size(300, 400))),
        verify: (MetadataBloc bloc) async {
          verify(mockedRepository.registerBackgroundChange(
            mockedImage,
            Size(300, 400),
          )).called(1);
        },
      );

      blocTest(
        'delete region event',
        build: () async => MetadataBloc(),
        act: (bloc) =>
            bloc.add(MetadataDeleteRegionEvent(Offset(10, 10), Size(10, 10))),
        verify: (MetadataBloc bloc) async {
          verify(mockedRepository.registerDeleteRegion(
              Offset(10, 10), Size(10, 10)));
        },
      );

      blocTest(
        'started, background and delete event',
        build: () async {
          when(mockedRepository.measurement)
              .thenAnswer((_) => Stream.fromIterable([true]));

          return MetadataBloc();
        },
        act: (bloc) async {
          bloc.add(startedEvent);
          bloc.add(MetadataBackgroundEvent(mockedImage, Size(300, 400)));
          bloc.add(MetadataDeleteRegionEvent(Offset(10, 10), Size(10, 10)));
        },
        verify: (MetadataBloc bloc) async {
          verifyInOrder([
            mockedRepository.registerStartupValuesChange(
              measurementInformation: measurementInformation,
              measure: measure,
              showDistance: showDistance,
              magnificationStyle: magnificationStyle,
              controller: measurementController,
            ),
            mockedRepository.registerBackgroundChange(
              mockedImage,
              Size(300, 400),
            ),
            mockedRepository.registerDeleteRegion(
              Offset(10, 10),
              Size(10, 10),
            ),
          ]);
        },
      );
    });
  });
}
