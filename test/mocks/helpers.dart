import 'package:bloc_test/bloc_test.dart';

import '../../lib/src/input_bloc/input_state.dart';
import '../../lib/src/measurement/bloc/magnification_bloc/magnification_state.dart';
import '../../lib/src/measurement/bloc/points_bloc/points_state.dart';
import '../../lib/src/metadata/bloc/metadata_state.dart';
import '../../lib/src/scale_bloc/scale_state.dart';

class FakeInputState extends Fake implements InputState {}

class FakeMagnificationState extends Fake implements MagnificationState {}

class FakePointsState extends Fake implements PointsState {}

class FakeMetadataState extends Fake implements MetadataState {}

class FakeScaleState extends Fake implements ScaleState {}

void registerStates() {
  registerFallbackValue(FakeInputState());
  registerFallbackValue(FakeMagnificationState());
  registerFallbackValue(FakePointsState());
  registerFallbackValue(FakeMetadataState());
  registerFallbackValue(FakeScaleState());
}
