import 'dart:async';

///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:measurements/metadata/repository/metadata_repository.dart';
import 'package:measurements/util/logger.dart';

import 'metadata_event.dart';
import 'metadata_state.dart';

class MetadataBloc extends Bloc<MetadataEvent, MetadataState> {
  final _logger = Logger(LogDistricts.METADATA_BLOC);
  final List<StreamSubscription> _streamSubscriptions = List();

  MetadataRepository _repository;
  bool _measure = false;
  double _zoom = 1.0;
  double _maxZoom = 5.0;

  MetadataBloc() {
    _repository = GetIt.I<MetadataRepository>();

    _streamSubscriptions.add(_repository.measurement.listen((bool measure) {
      _measure = measure;
      _updateState();
    }));
    _streamSubscriptions.add(_repository.zoom.listen((zoom) {
      _zoom = zoom;
      _updateState();
    }));
    _streamSubscriptions.add(_repository.orientation.listen((orientation) => _updateState()));
  }

  void _updateState() {
    add(MetadataUpdatedEvent(_measure, _zoom, _maxZoom));
  }

  @override
  MetadataState get initialState => MetadataState(_measure, _zoom, _maxZoom);

  @override
  void onEvent(MetadataEvent event) async {
    _logger.log("received event: $event");

    if (event is MetadataStartedEvent) {
      _repository.registerStartupValuesChange(
        measurementInformation: event.measurementInformation,
        measure: event.measure,
        showDistance: event.showDistances,
        controller: event.controller,
        magnificationStyle: event.magnificationStyle,
      );
    } else if (event is MetadataBackgroundEvent) {
      _repository.registerBackgroundChange(event.backgroundImage, event.size);

      _maxZoom = await _repository.zoomFactorForOriginalSize;
    } else if (event is MetadataDeleteRegionEvent) {
      _repository.registerDeleteRegion(event.position, event.deleteSize);
    }

    super.onEvent(event);
  }

  @override
  Stream<MetadataState> mapEventToState(MetadataEvent event) async* {
    if (event is MetadataUpdatedEvent) {
      yield MetadataState(event.measure, event.zoom, event.maxZoom);
    }
  }
}
