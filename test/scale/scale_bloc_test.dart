import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:measurements/metadata/repository/metadata_repository.dart';
import 'package:measurements/scale_bloc/scale_bloc.dart';
import 'package:measurements/scale_bloc/scale_event.dart';
import 'package:measurements/scale_bloc/scale_state.dart';
import 'package:mockito/mockito.dart';

import '../mocks/test_mocks.dart';

///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

void main() {
  group("Scale Bloc Test", () {
    MetadataRepository mockedMetadataRepository;

    setUp(() {
      mockedMetadataRepository = MockedMetadataRepository();

      when(mockedMetadataRepository.measurement).thenAnswer((_) => Stream.fromIterable([false]));
      when(mockedMetadataRepository.screenSize).thenAnswer((_) => Stream.fromIterable([Size(10, 10)]));
      when(mockedMetadataRepository.zoomFactorForOriginalSize).thenAnswer((_) async => 2.0);
      when(mockedMetadataRepository.zoomFactorToFillScreen).thenReturn(5.0);

      GetIt.I.registerSingleton(mockedMetadataRepository);
    });

    tearDown(() {
      GetIt.I.unregister(instance: mockedMetadataRepository);
    });

    blocTest(
      "initial state",
      build: () async => ScaleBloc(),
      skip: 0,
      expect: [
        ScaleState(Offset(0, 0), 1.0, Matrix4.identity()),
      ],
    );

    group("single touch events", () {
      blocTest(
        "panning",
        build: () async => ScaleBloc(),
        act: (bloc) async {
          bloc.add(ScaleStartEvent(Offset(0, 0)));
          bloc.add(ScaleUpdateEvent(Offset(10, 0), 1.0));
        },
        expect: [
          ScaleState(Offset(10, 0), 1.0, Matrix4.identity()..translate(10.0)),
        ],
      );

      blocTest(
        "zooming",
        build: () async => ScaleBloc(),
        act: (bloc) async {
          bloc.add(ScaleStartEvent(Offset(0, 0)));
          bloc.add(ScaleUpdateEvent(Offset(10, 0), 2.0));
        },
        expect: [
          ScaleState(Offset(0, 0), 2.0, Matrix4.identity()..scale(2.0)),
        ],
      );

      blocTest(
        "zoom and then pan",
        build: () async => ScaleBloc(),
        act: (bloc) async {
          bloc.add(ScaleStartEvent(Offset(0, 0)));
          bloc.add(ScaleUpdateEvent(Offset(10, 0), 2.0));

          bloc.add(ScaleStartEvent(Offset(0, 0)));
          bloc.add(ScaleUpdateEvent(Offset(10, 0), 1.0));
        },
        expect: [
          ScaleState(
              Offset(10, 0),
              2.0,
              Matrix4.identity()
                ..translate(10.0)
                ..scale(2.0)),
        ],
      );

      blocTest(
        "zoom twice",
        build: () async => ScaleBloc(),
        act: (bloc) async {
          bloc.add(ScaleStartEvent(Offset(0, 0)));
          bloc.add(ScaleUpdateEvent(Offset(10, 0), 2.0));

          bloc.add(ScaleStartEvent(Offset(0, 0)));
          bloc.add(ScaleUpdateEvent(Offset(10, 0), 3.0));
        },
        expect: [
          ScaleState(Offset(0, 0), 6.0, Matrix4.identity()..scale(6.0)),
        ],
      );
    });

    group("double tap", () {
      blocTest(
        "single double tap event",
        build: () async => ScaleBloc(),
        act: (bloc) async => bloc.add(ScaleDoubleTapEvent()),
        expect: [
          ScaleState(Offset(0, 0), 5.0, Matrix4.identity()..scale(5.0)),
        ],
      );
    });

    group("measurement function calls", () {
      blocTest(
        "single double tap event",
        build: () async => ScaleBloc(),
        act: (bloc) async {
          (bloc as ScaleBloc).zoomToOriginal();
        },
        expect: [
          ScaleState(Offset(0, 0), 2.0, Matrix4.identity()..scale(2.0)),
        ],
      );
    });
  });
}
