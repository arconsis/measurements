import'package:flutter_bloc/flutter_bloc.dart';
import 'package:measurements/metadata/repository/metadata_repository.dart';

import '../metadata_event.dart';
import '../metadata_state.dart';

class MetadataBloc extends Bloc<MetadataEvent, MetadataState> {
  final MetadataRepository _repository;
  final _initialMeasure = false;

  MetadataBloc(this._repository) {
    _repository.enableMeasure.listen((bool measure) {
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
      _registerStartedEvent(event);
    } else if (event is MetadataBackgroundEvent) {
      _registerBackgroundEvent(event);
    } else if (event is MetadataOrientationEvent) {
      _registerOrientationEvent(event);
    }
  }

  void _registerStartedEvent(MetadataStartedEvent event) {
    _repository.enableMeasure.add(event.measure);
    _repository.showDistance.add(event.showDistances);
    _repository.distanceCallback.add(event.callback);
    _repository.scale.add(event.scale);
    _repository.zoomLevel.add(event.zoom);
    _repository.documentSize.add(event.documentSize);
  }

  void _registerBackgroundEvent(MetadataBackgroundEvent event) {
    _repository.currentBackgroundImage.add(event.backgroundImage);
    _repository.viewWidth.add(event.width);
  }

  void _registerOrientationEvent(MetadataOrientationEvent event) {
    _repository.orientation.add(event.orientation);
  }
}