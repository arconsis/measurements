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
import 'package:photo_view/photo_view.dart';
import 'package:rxdart/rxdart.dart';

import '../../mocks/test_mocks.dart';

void main() {
  group("Metadata Bloc Unit Test", () {
    MetadataRepository mockedRepository;
    BehaviorSubject<bool> measurement;
    Image mockedImage;
    PhotoViewController mockedPhotoController;

    final measurementInformation = MeasurementInformation(documentWidthInLengthUnits: Millimeter(210), scale: 1.0);
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
      mockedPhotoController = MockedPhotoViewController();
      GetIt.I.registerSingleton(mockedRepository);

      when(mockedRepository.measurement).thenAnswer((_) => Stream.fromIterable([]));
      when(mockedRepository.zoom).thenAnswer((_) => Stream.fromIterable([]));
      when(mockedRepository.orientation).thenAnswer((_) => Stream.fromIterable([]));
    });

    tearDown(() {
      GetIt.I.unregister(instance: mockedRepository);
      measurement?.close();
    });

    blocTest("initial state",
      skip: 0,
      build: () async => MetadataBloc(),
      verify: (MetadataBloc bloc) {
        expect(bloc.state.controller, isA<PhotoViewController>());
        expect(bloc.state.measure, equals(false));

        return;
      },
    );

    group("metadata events", () {
      blocTest("started event should show measurements",
        build: () async {
          when(mockedRepository.measurement).thenAnswer((_) => Stream.fromIterable([true]));

          return MetadataBloc();
        },
        act: (bloc) => bloc.add(startedEvent),
        verify: (MetadataBloc bloc) {
          expect(bloc.state.controller, isA<PhotoViewController>());
          expect(bloc.state.measure, equals(true));

          return;
        },
      );

      blocTest("background registered",
        skip: 0,
        build: () async => MetadataBloc(),
        act: (bloc) => bloc.add(MetadataBackgroundEvent(mockedImage, Size(300, 400))),
        verify: (MetadataBloc bloc) {
          expect(bloc.state.controller, isA<PhotoViewController>());
          expect(bloc.state.measure, equals(false));

          return;
        },
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
        verify: (MetadataBloc bloc) {
          expect(bloc.state.controller, isA<PhotoViewController>());
          expect(bloc.state.measure, equals(true));

          return;
        },
      );
    });

    group("UI events", () {
      List<MetadataState> states;

      setUp(() {
        states = List();
      });

      blocTest("enable and disable measurement",
        build: () async {
          when(mockedRepository.measurement).thenAnswer((_) => Stream.fromIterable([true, false]));

          final bloc = MetadataBloc();
          bloc.listen(states.add);

          return bloc;
        },
        verify: (MetadataBloc bloc) async {
          states.forEach((state) => expect(state.controller, isA<PhotoViewController>()));

          expect(states[0].measure, equals(false));
          expect(states[1].measure, equals(true));
          expect(states[2].measure, equals(false));

          return;
        },
      );
    });

    group("measure functions", () {
      final expectedZoomFactor = 5.5;

      blocTest("reset zoom",
        build: () async => MetadataBloc(),
        act: (bloc) async {
          (bloc as MeasurementFunction).resetZoom();
        },
        verify: (bloc) async {
          final initialState = (bloc as MetadataBloc).initialState;

          expect(initialState.controller.scale, 1.0);
        },
      );

      blocTest("zoom to original",
        build: () async {
          when(mockedRepository.zoomFactorForOriginalSize).thenAnswer((realInvocation) async => expectedZoomFactor);

          return MetadataBloc();
        },
        act: (bloc) async {
          (bloc as MeasurementFunction).zoomToOriginal();
        },
        verify: (bloc) async {
          final initialState = (bloc as MetadataBloc).initialState;

          expect(initialState.controller.scale, expectedZoomFactor);
        },
      );
    });
  });
}