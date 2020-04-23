import'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:measurements/metadata/repository/metadata_repository.dart';

import 'metadata_event.dart';
import 'metadata_state.dart';

class MetadataBloc extends Bloc<MetadataEvent, MetadataState> {
  MetadataRepository _repository;
  final _initialMeasure = false;

  MetadataBloc() {
    _repository = GetIt.I<MetadataRepository>();

    _repository.measurement.listen((bool measure) {
      add(MetadataUpdatedEvent(measure));
    });
  }

  @override
  MetadataState get initialState => MetadataState(_initialMeasure);

  @override
  Stream<MetadataState> mapEventToState(MetadataEvent event) async* {
    if (event is MetadataUpdatedEvent) {
      yield MetadataState(event.measure);
    } else if (event is MetadataStartedEvent) {
      _repository.registerStartupValuesChange(
          event.measure,
          event.showDistances,
          event.callback,
          event.scale,
          event.zoom,
          event.documentSize
      );
    } else if (event is MetadataBackgroundEvent) {
      _repository.registerBackgroundChange(event.backgroundImage, event.size);
    } else if (event is MetadataOrientationEvent) {
      _repository.registerOrientationChange(event.orientation);
    }
  }
}