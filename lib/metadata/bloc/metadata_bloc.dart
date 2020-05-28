import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:measurements/metadata/repository/metadata_repository.dart';
import 'package:measurements/util/logger.dart';
import 'package:photo_view/photo_view.dart';

import 'metadata_event.dart';
import 'metadata_state.dart';

class MetadataBloc extends Bloc<MetadataEvent, MetadataState> {
  final _logger = Logger(LogDistricts.METADATA_BLOC);

  MetadataRepository _repository;
  PhotoViewController _controller;

  MetadataBloc() {
    _repository = GetIt.I<MetadataRepository>();

    _repository.measurement.listen((bool measure) {
      add(MetadataUpdatedEvent(measure));
    });

    _controller = PhotoViewController();

    _controller.outputStateStream.listen((state) {

    });

    _logger.log("Created Bloc");
  }

  @override
  MetadataState get initialState => MetadataState(_controller);

  @override
  void onEvent(MetadataEvent event) {
    _logger.log("received event: $event");

    if (event is MetadataStartedEvent) {
      _repository.registerStartupValuesChange(
          event.measure,
          event.showDistances,
          event.callback,
          event.toleranceCallback,
          event.scale,
          event.documentSize,
          event.magnificationStyle
      );
    } else if (event is MetadataBackgroundEvent) {
      _repository.registerBackgroundChange(event.backgroundImage, event.size);
    }

    super.onEvent(event);
  }

  @override
  Stream<MetadataState> mapEventToState(MetadataEvent event) async* {
    yield MetadataState(_controller);
  }

  @override
  Future<void> close() {
    _controller?.dispose();
    return super.close();
  }
}