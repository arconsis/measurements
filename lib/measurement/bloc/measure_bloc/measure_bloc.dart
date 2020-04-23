import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:measurements/measurement/bloc/measure_bloc/measure_event.dart';
import 'package:measurements/measurement/bloc/measure_bloc/measure_state.dart';
import 'package:measurements/measurement/repository/measurement_repository.dart';
import 'package:measurements/metadata/repository/metadata_repository.dart';
import 'package:measurements/util/logger.dart';
import 'package:measurements/util/size.dart';

class MeasureBloc extends Bloc<MeasureEvent, MeasureState> {
  final _logger = Logger(LogDistricts.MEASURE_BLOC);

  MeasurementRepository _measureRepository;
  MetadataRepository _metadataRepository;

  Image backgroundImage;
  double imageScaleFactor;

  MeasureBloc() {
    _measureRepository = GetIt.I<MeasurementRepository>();

    _metadataRepository = GetIt.I<MetadataRepository>();

    _metadataRepository.backgroundImage.listen((image) => backgroundImage = image);
    _metadataRepository.imageScaleFactor.listen((factor) => imageScaleFactor = factor);

    _logger.log("Created Bloc");
  }

  @override
  MeasureState get initialState => MeasureInactiveState();

  @override
  void onEvent(MeasureEvent event) {
    _logger.log("received event: $event");

    if (event is MeasureDownEvent) {
      _measureRepository.registerDownEvent(event.position);
    } else if (event is MeasureMoveEvent) {
      _measureRepository.registerMoveEvent(event.position);
    } else if (event is MeasureUpEvent) {
      _measureRepository.registerUpEvent(event.position);
    }

    super.onEvent(event);
  }

  @override
  Stream<MeasureState> mapEventToState(MeasureEvent event) async* {
    // TODO is there a nicer way to get the background image from the event? maybe transformEvents or onEvent
    if (event is MeasureDownEvent) {
      yield MeasureActiveState(event.position, backgroundImage, imageScaleFactor, magnificationRadius);
    } else if (event is MeasureMoveEvent) {
      yield MeasureActiveState(event.position, backgroundImage, imageScaleFactor, magnificationRadius);
    } else if (event is MeasureUpEvent) {
      yield MeasureInactiveState();
    }
  }
}
