import 'dart:ui';

import 'package:measurements/measurement/repository/measurement_repository.dart';
import 'package:measurements/metadata/repository/metadata_repository.dart';
import 'package:mockito/mockito.dart';

class MockedMetadataRepository extends Mock implements MetadataRepository {}

class MockedMeasurementRepository extends Mock implements MeasurementRepository {}

class MockedImage extends Mock implements Image {
  static final _mockedImage = MockedImage._private();

  MockedImage._private();

  static MockedImage get mock => _mockedImage;
}