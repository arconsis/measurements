import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:document_measure/src/metadata/repository/metadata_repository.dart';
import 'package:document_measure/src/scale_bloc/scale_bloc.dart';
import 'package:document_measure/src/scale_bloc/scale_event.dart';
import 'package:document_measure/src/scale_bloc/scale_state.dart';
import 'package:mockito/mockito.dart';

import '../mocks/test_mocks.dart';

/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

void main() {
  group('Scale Bloc Test', () {
    MetadataRepository mockedMetadataRepository;
    final defaultOffset = Offset(25, 50);

    setUp(() {
      mockedMetadataRepository = MockedMetadataRepository();

      when(mockedMetadataRepository.measurement).thenAnswer((_) => Stream.fromIterable([false]));
      when(mockedMetadataRepository.viewSize).thenAnswer((_) => Stream.fromIterable([Size(50, 100)]));
      when(mockedMetadataRepository.screenSize).thenAnswer((_) => Stream.fromIterable([Size(100, 200)]));
      when(mockedMetadataRepository.zoomFactorForLifeSize).thenAnswer((_) async => 2.0);
      when(mockedMetadataRepository.zoomFactorToFillScreen).thenReturn(5.0);
      when(mockedMetadataRepository.isDocumentWidthAlignedWithScreenWidth(any)).thenReturn(true);

      GetIt.I.registerSingleton(mockedMetadataRepository);
    });

    tearDown(() {
      GetIt.I.unregister(instance: mockedMetadataRepository);
    });

    blocTest(
      'initial state',
      build: () async => ScaleBloc(),
      skip: 0,
      expect: [
        ScaleState(Offset(0, 0), 1.0, Matrix4.identity()),
        ScaleState(defaultOffset, 1.0, Matrix4.identity()..translate(defaultOffset.dx, defaultOffset.dy)),
      ],
    );

    group('single touch events', () {
      blocTest(
        'panning',
        build: () async => ScaleBloc(),
        act: (bloc) async {
          bloc.add(ScaleStartEvent(Offset(0, 0)));
          bloc.add(ScaleUpdateEvent(Offset(10, 0), 1.0));
        },
        expect: [
          ScaleState(defaultOffset + Offset(10, 0), 1.0, Matrix4.identity()..translate(defaultOffset.dx + 10.0, defaultOffset.dy)),
        ],
      );

      blocTest(
        'zooming',
        build: () async => ScaleBloc(),
        act: (bloc) async {
          bloc.add(ScaleStartEvent(Offset(0, 0)));
          bloc.add(ScaleUpdateEvent(Offset(10, 0), 2.0));
        },
        expect: [
          ScaleState(
              defaultOffset,
              2.0,
              Matrix4.identity()
                ..translate(defaultOffset.dx, defaultOffset.dy)
                ..scale(2.0)),
        ],
      );

      blocTest(
        'zooming out should clamp at 1.0',
        build: () async => ScaleBloc(),
        act: (bloc) async {
          bloc.add(ScaleStartEvent(Offset(0, 0)));
          bloc.add(ScaleUpdateEvent(Offset(10, 0), 0.12));
        },
        expect: [
          ScaleState(
              defaultOffset,
              1.0,
              Matrix4.identity()
                ..translate(defaultOffset.dx, defaultOffset.dy)
                ..scale(1.0)),
        ],
      );

      blocTest(
        'zoom and then pan',
        build: () async => ScaleBloc(),
        act: (bloc) async {
          bloc.add(ScaleStartEvent(Offset(0, 0)));
          bloc.add(ScaleUpdateEvent(Offset(10, 0), 2.0));

          bloc.add(ScaleStartEvent(Offset(0, 0)));
          bloc.add(ScaleUpdateEvent(Offset(10, 0), 1.0));
        },
        expect: [
          ScaleState(
              defaultOffset + Offset(10, 0),
              2.0,
              Matrix4.identity()
                ..translate(defaultOffset.dx + 10, defaultOffset.dy)
                ..scale(2.0)),
        ],
      );

      blocTest(
        'zoom twice',
        build: () async => ScaleBloc(),
        act: (bloc) async {
          bloc.add(ScaleStartEvent(Offset(0, 0)));
          bloc.add(ScaleUpdateEvent(Offset(10, 0), 2.0));

          bloc.add(ScaleStartEvent(Offset(0, 0)));
          bloc.add(ScaleUpdateEvent(Offset(10, 0), 3.0));
        },
        expect: [
          ScaleState(
              defaultOffset,
              6.0,
              Matrix4.identity()
                ..translate(defaultOffset.dx, defaultOffset.dy)
                ..scale(6.0)),
        ],
      );
    });

    group('double tap', () {
      blocTest(
        'single double tap event',
        build: () async => ScaleBloc(),
        act: (bloc) async => bloc.add(ScaleDoubleTapEvent()),
        expect: [
          ScaleState(
              defaultOffset,
              5.0,
              Matrix4.identity()
                ..translate(defaultOffset.dx, defaultOffset.dy)
                ..scale(5.0)),
        ],
      );
    });
  });
}
