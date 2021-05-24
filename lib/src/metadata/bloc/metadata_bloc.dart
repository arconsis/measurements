/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'dart:async';

import 'package:document_measure/src/metadata/repository/metadata_repository.dart';
import 'package:document_measure/src/util/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'metadata_event.dart';
import 'metadata_state.dart';

class MetadataBloc extends Bloc<MetadataEvent, MetadataState> {
  final _logger = Logger(LogDistricts.METADATA_BLOC);

  MetadataRepository _repository;

  MetadataBloc() : super(MetadataState()) {
    _repository = GetIt.I<MetadataRepository>();
  }

  @override
  void onEvent(MetadataEvent event) async {
    _logger.log('received event: $event');

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
    } else if (event is MetadataDeleteRegionEvent) {
      _repository.registerDeleteRegion(event.position, event.deleteSize);
    } else if (event is MetadataScreenSizeEvent) {
      _repository.registerScreenSize(event.screenSize);
    }

    super.onEvent(event);
  }

  @override
  Stream<MetadataState> mapEventToState(MetadataEvent event) async* {}
}
