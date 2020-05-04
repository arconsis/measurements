import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:measurements/metadata/bloc/metadata_bloc.dart';
import 'package:measurements/metadata/bloc/metadata_event.dart';
import 'package:measurements/metadata/bloc/metadata_state.dart';
import 'package:measurements/metadata/repository/metadata_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';

class MockMetadataRepository extends Mock implements MetadataRepository {}

class MockImage extends Mock implements Image {}

void main() {
  group("Metadata Bloc Test", () {
    MetadataBloc metadataBloc;
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

      when(mockedRepository.measurement).thenAnswer((_) => measurement.stream);
      when(mockedRepository.registerStartupValuesChange(any, any, any, any, any, any)).thenAnswer((invocation) {
        measurement.add(invocation.positionalArguments[0]);
      });

      metadataBloc = MetadataBloc();
    });

    tearDown(() {
      GetIt.I.unregister(instance: mockedRepository);
      metadataBloc?.close();
      measurement?.close();
    });

    blocTest("initial state",
        skip: 0,
        build: () async => metadataBloc,
        expect: [MetadataState(false)]);


    group("metadata events", () {
      blocTest("started event should show measurements",
          build: () async {
            return metadataBloc;
          },
          act: (bloc) => bloc.add(startedEvent),
          expect: [MetadataState(true)]
      );

      blocTest("background registered",
          skip: 0,
          build: () async => metadataBloc,
          act: (bloc) => bloc.add(MetadataBackgroundEvent(mockedImage, Size(300, 400))),
          expect: [MetadataState(false)]
      );

      blocTest("started and background event",
          build: () async => metadataBloc,
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
          build: () async => metadataBloc,
          act: (bloc) {
            bloc.add(MetadataUpdatedEvent(true));
            bloc.add(MetadataUpdatedEvent(false));

            return;
          },
          expect: [MetadataState(true), MetadataState(false)]);
    });
  });
}