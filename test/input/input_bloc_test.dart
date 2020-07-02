import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:measurements/input_state/input_bloc.dart';
import 'package:measurements/input_state/input_event.dart';
import 'package:measurements/input_state/input_state.dart';
import 'package:measurements/measurement/repository/measurement_repository.dart';
import 'package:measurements/metadata/repository/metadata_repository.dart';
import 'package:mockito/mockito.dart';

import '../mocks/test_mocks.dart';

///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

void main() {
  group("Input Bloc Test", () {
    MetadataRepository mockedMetadataRepository;
    MeasurementRepository mockedMeasurementRepository;

    setUp(() {
      mockedMetadataRepository = MockedMetadataRepository();
      mockedMeasurementRepository = MockedMeasurementRepository();

      when(mockedMetadataRepository.measurement).thenAnswer((_) => Stream.fromIterable([]));

      GetIt.I.registerSingleton(mockedMetadataRepository);
      GetIt.I.registerSingleton(mockedMeasurementRepository);
    });

    tearDown(() {
      GetIt.I.unregister(instance: mockedMeasurementRepository);
      GetIt.I.unregister(instance: mockedMetadataRepository);
    });

    blocTest(
      "initial state",
      build: () async => InputBloc(),
      skip: 0,
      expect: [InputEmptyState()],
    );

    group("with measuring", () {
      Rect deleteRegion = Rect.fromPoints(Offset(10, 10), Offset(20, 20));

      setUp(() {
        when(mockedMetadataRepository.measurement).thenAnswer((_) => Stream.fromIterable([true]));
        when(mockedMetadataRepository.isInDeleteRegion(any)).thenAnswer((realInvocation) => deleteRegion.contains(realInvocation.positionalArguments[0]));
      });

      blocTest(
        "down move up all outside of delete area",
        build: () async => InputBloc(),
        act: (bloc) async {
          bloc.add(InputDownEvent(Offset(50, 50)));
          bloc.add(InputMoveEvent(Offset(60, 60)));
          bloc.add(InputUpEvent(Offset(70, 70)));
        },
        expect: [
          InputStandardState(Offset(50, 50)),
          InputStandardState(Offset(60, 60)),
          InputEndedState(Offset(70, 70)),
        ],
      );

      blocTest(
        "down outside then move to delete area and up in there",
        build: () async => InputBloc(),
        act: (bloc) async {
          bloc.add(InputDownEvent(Offset(50, 50)));
          bloc.add(InputMoveEvent(Offset(15, 15)));
          bloc.add(InputUpEvent(Offset(15, 15)));
        },
        expect: [
          InputStandardState(Offset(50, 50)),
          InputDeleteRegionState(Offset(15, 15)),
          InputDeleteState(),
        ],
      );

      blocTest(
        "down move up all in delete area",
        build: () async => InputBloc(),
        act: (bloc) async {
          bloc.add(InputDownEvent(Offset(12, 12)));
          bloc.add(InputMoveEvent(Offset(15, 15)));
          bloc.add(InputUpEvent(Offset(16, 16)));
        },
        expect: [
          InputStandardState(Offset(12, 12)),
          InputStandardState(Offset(15, 15)),
          InputEndedState(Offset(16, 16)),
        ],
      );

      blocTest(
        "down in delete area then move out and up",
        build: () async => InputBloc(),
        act: (bloc) async {
          bloc.add(InputDownEvent(Offset(12, 12)));
          bloc.add(InputMoveEvent(Offset(60, 60)));
          bloc.add(InputUpEvent(Offset(70, 70)));
        },
        expect: [
          InputStandardState(Offset(12, 12)),
          InputStandardState(Offset(60, 60)),
          InputEndedState(Offset(70, 70)),
        ],
      );

      blocTest(
        "down in delete area then move outside and back in and up in delete area",
        build: () async => InputBloc(),
        act: (bloc) async {
          bloc.add(InputDownEvent(Offset(12, 12)));
          bloc.add(InputMoveEvent(Offset(60, 60)));
          bloc.add(InputMoveEvent(Offset(15, 15)));
          bloc.add(InputUpEvent(Offset(70, 70)));
        },
        expect: [
          InputStandardState(Offset(12, 12)),
          InputStandardState(Offset(60, 60)),
          InputStandardState(Offset(15, 15)),
          InputEndedState(Offset(70, 70)),
        ],
      );
    });

    group("without measuring", () {
      setUp(() {
        when(mockedMetadataRepository.measurement).thenAnswer((_) => Stream.fromIterable([false]));
      });

      blocTest(
        "down move up should ignore all",
        build: () async => InputBloc(),
        act: (bloc) async {
          bloc.add(InputDownEvent(Offset(12, 12)));
          bloc.add(InputMoveEvent(Offset(15, 15)));
          bloc.add(InputUpEvent(Offset(70, 70)));
        },
        expect: [
          InputEmptyState(),
          InputEmptyState(),
          InputEmptyState(),
        ],
      );
    });
  });
}
