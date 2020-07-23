import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:measurements/src/input_bloc/input_bloc.dart';
import 'package:measurements/src/input_bloc/input_event.dart';
import 'package:measurements/src/input_bloc/input_state.dart';
import 'package:measurements/src/measurement/repository/measurement_repository.dart';
import 'package:measurements/src/metadata/repository/metadata_repository.dart';
import 'package:mockito/mockito.dart';

class MockedMetadataRepository extends Mock implements MetadataRepository {}

class MockedMeasurementRepository extends Mock implements MeasurementRepository {}

class MockedInputBloc extends MockBloc<InputEvent, InputState> implements InputBloc {}

class MockedImage extends Mock implements Image {
  static final _mockedImage = MockedImage._private();

  MockedImage._private();

  static MockedImage get mock => _mockedImage;
}
