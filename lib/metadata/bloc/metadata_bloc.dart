import 'package:flutter/cupertino.dart';

///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:measurements/measurement_controller.dart';
import 'package:measurements/metadata/repository/metadata_repository.dart';
import 'package:measurements/util/logger.dart';
import 'package:photo_view/photo_view.dart';

import 'metadata_event.dart';
import 'metadata_state.dart';

class MetadataBloc extends Bloc<MetadataEvent, MetadataState> implements MeasurementFunction {
  final _logger = Logger(LogDistricts.METADATA_BLOC);

  MetadataRepository _repository;
  PhotoViewController _controller = PhotoViewController();
  bool _measure = false;
  double _zoom = 1.0;
  double _maxZoom = 5.0;
  Orientation _orientation = Orientation.portrait;

  MetadataBloc() {
    _repository = GetIt.I<MetadataRepository>();

    _repository.measurement.listen((bool measure) {
      _measure = measure;
      _updateState();
    });
    _repository.zoom.listen((zoom) {
      _zoom = zoom;
      _updateState();
    });
    _repository.orientation.listen((orientation) {
      _orientation = orientation;
      _updateState();
    });

    _controller.outputStateStream.listen((state) => _repository.registerResizing(state.position, state.scale));
  }

  void _updateState() {
    add(MetadataUpdatedEvent(_measure, _orientation, _zoom, _maxZoom));
  }

  @override
  MetadataState get initialState => MetadataState(_controller, _measure, _zoom, _maxZoom, _orientation);

  @override
  void onEvent(MetadataEvent event) async {
    _logger.log("received event: $event");

    if (event is MetadataStartedEvent) {
      event.controller?.measurementFunction = this;

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
    } else if (event is MetadataOrientationEvent) {
      _repository.registerOrientation(event.orientation);
    }

    super.onEvent(event);
  }

  @override
  Stream<MetadataState> mapEventToState(MetadataEvent event) async* {
    if (event is MetadataUpdatedEvent) {
      yield MetadataState(_controller, event.measure, event.zoom, event.maxZoom, event.orientation);
    }
  }

  @override
  Future<void> close() {
    _controller?.dispose();
    return super.close();
  }

  @override
  void zoomToOriginal() async => _controller.scale = await _repository.zoomFactorForOriginalSize;

  @override
  void resetZoom() => _controller.scale = 1.0;
}