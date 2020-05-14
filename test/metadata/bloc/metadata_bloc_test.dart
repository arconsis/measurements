import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:measurements/metadata/bloc/metadata_bloc.dart';
import 'package:measurements/metadata/bloc/metadata_event.dart';
import 'package:measurements/metadata/bloc/metadata_state.dart';
import 'package:measurements/metadata/repository/metadata_repository.dart';
import 'package:measurements/util/size.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';

class MockMetadataRepository extends Mock implements MetadataRepository {}

class MockImage extends Mock implements Image {}

void main() {
  group("Metadata Bloc Unit Test", () {
    MetadataRepository mockedRepository;
    BehaviorSubject<bool> measurement;
    Image mockedImage;

    final documentSize = Size(210, 297);
    final scale = 1.0;
    final zoom = 1.0;
    final measure = true;
    final showDistance = true;

    final startedEvent = MetadataStartedEvent(
        documentSize,
        null,
        scale,
        zoom,
        measure,
        showDistance,
        null
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
          when(mockedRepository.magnificationRadius).thenAnswer((_) => Stream.fromIterable([magnificationRadius]));

          return MetadataBloc();
        },
        expect: [MetadataState(false, magnificationRadius)]);

    group("metadata events", () {
      blocTest("started event should show measurements",
          build: () async {
            when(mockedRepository.measurement).thenAnswer((_) => Stream.fromIterable([true]));
            when(mockedRepository.magnificationRadius).thenAnswer((_) => Stream.fromIterable([magnificationRadius]));

            return MetadataBloc();
          },
          act: (bloc) => bloc.add(startedEvent),
          expect: [MetadataState(true, magnificationRadius)]
      );

      blocTest("background registered",
          skip: 0,
          build: () async {
            when(mockedRepository.measurement).thenAnswer((_) => Stream.fromIterable([]));
            when(mockedRepository.magnificationRadius).thenAnswer((_) => Stream.fromIterable([magnificationRadius]));

            return MetadataBloc();
          },
          act: (bloc) => bloc.add(MetadataBackgroundEvent(mockedImage, Size(300, 400))),
          expect: [MetadataState(false, magnificationRadius)]
      );

      blocTest("started and background event",
          build: () async {
            when(mockedRepository.measurement).thenAnswer((_) => Stream.fromIterable([true]));
            when(mockedRepository.magnificationRadius).thenAnswer((_) => Stream.fromIterable([magnificationRadius]));

            return MetadataBloc();
          },
          act: (bloc) {
            bloc.add(startedEvent);
            bloc.add(MetadataBackgroundEvent(mockedImage, Size(300, 400)));
            return;
          },
          expect: [MetadataState(true, magnificationRadius)]
      );
    });

    group("UI events", () {
      blocTest("enable and disable measurement",
          build: () async {
            when(mockedRepository.measurement).thenAnswer((_) => Stream.fromIterable([true, false]));
            when(mockedRepository.magnificationRadius).thenAnswer((_) => Stream.fromIterable([magnificationRadius]));

            return MetadataBloc();
          },
          expect: [MetadataState(true, magnificationRadius), MetadataState(false, magnificationRadius)]
      );

      blocTest("enable measurement and change magnification radius",
        build: () async {
          when(mockedRepository.measurement).thenAnswer((_) => Stream.fromIterable([true]));
          when(mockedRepository.magnificationRadius).thenAnswer((_) => Stream.fromIterable([60]));

          return MetadataBloc();
        },
        skip: 0,
        expect: [MetadataState(false, magnificationRadius), MetadataState(false, 60), MetadataState(true, 60)],
      );
    });
  });
}