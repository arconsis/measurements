///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:measurements/measurements.dart';
import 'package:measurements/metadata/bloc/metadata_bloc.dart';
import 'package:measurements/metadata/bloc/metadata_event.dart';
import 'package:measurements/metadata/bloc/metadata_state.dart';
import 'package:measurements/metadata/repository/metadata_repository.dart';
import 'package:measurements/style/magnification_style.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';

class MockMetadataRepository extends Mock implements MetadataRepository {}

class MockImage extends Mock implements Image {}

void main() {
  group("Metadata Bloc Unit Test", () {
    MetadataRepository mockedRepository;
    BehaviorSubject<bool> measurement;
    Image mockedImage;

    final measurementInformation = MeasurementInformation(documentWidthInLengthUnits: Millimeter(210), scale: 1.0);
    final zoom = 1.0;
    final measure = true;
    final showDistance = true;
    final magnificationStyle = MagnificationStyle();

    final startedEvent = MetadataStartedEvent(
      measurementInformation: measurementInformation,
      zoom: zoom,
      measure: measure,
      showDistances: showDistance,
      magnificationStyle: magnificationStyle,
      callback: null,
      toleranceCallback: null,
    );

    setUp(() {
      mockedImage = MockImage();
      measurement = BehaviorSubject();
      mockedRepository = MockMetadataRepository();
      GetIt.I.registerSingleton(mockedRepository);
    });

    tearDown(() {
      GetIt.I.unregister(instance: mockedRepository);
      measurement?.close();
    });

    blocTest("initial state",
        skip: 0,
        build: () async {
          when(mockedRepository.measurement).thenAnswer((_) => Stream.fromIterable([]));

          return MetadataBloc();
        },
        expect: [MetadataState(false)]);

    group("metadata events", () {
      blocTest("started event should show measurements",
          build: () async {
            when(mockedRepository.measurement).thenAnswer((_) => Stream.fromIterable([true]));

            return MetadataBloc();
          },
          act: (bloc) => bloc.add(startedEvent),
          expect: [MetadataState(true)]
      );

      blocTest("background registered",
          skip: 0,
          build: () async {
            when(mockedRepository.measurement).thenAnswer((_) => Stream.fromIterable([]));

            return MetadataBloc();
          },
          act: (bloc) => bloc.add(MetadataBackgroundEvent(mockedImage, Size(300, 400))),
          expect: [MetadataState(false)]
      );

      blocTest("started and background event",
          build: () async {
            when(mockedRepository.measurement).thenAnswer((_) => Stream.fromIterable([true]));

            return MetadataBloc();
          },
          act: (bloc) {
            bloc.add(startedEvent);
            bloc.add(MetadataBackgroundEvent(mockedImage, Size(300, 400)));
            return;
          },
          expect: [MetadataState(true)]
      );
    });

    group("UI events", () {
      blocTest("enable and disable measurement",
          build: () async {
            when(mockedRepository.measurement).thenAnswer((_) => Stream.fromIterable([true, false]));

            return MetadataBloc();
          },
          expect: [MetadataState(true), MetadataState(false)]
      );
    });
  });
}