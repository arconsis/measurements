import 'dart:ui' as ui;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:measurements/measurement/bloc/measure_bloc/measure_event.dart';
import 'package:measurements/measurement/bloc/measure_bloc/measure_state.dart';
import 'package:measurements/measurement/repository/measurement_repository.dart';
import 'package:measurements/metadata/repository/metadata_repository.dart';
import 'package:measurements/util/logger.dart';

class MeasureBloc extends Bloc<MeasureEvent, MeasureState> {
  final _logger = Logger(LogDistricts.MEASURE_BLOC);

  MeasurementRepository _measureRepository;
  MetadataRepository _metadataRepository;

  ui.Image _backgroundImage;
  double _imageScaleFactor;

  MeasureBloc() {
    _measureRepository = GetIt.I<MeasurementRepository>();
    _metadataRepository = GetIt.I<MetadataRepository>();

    _metadataRepository.backgroundImage.listen((ui.Image image) {
      _logger.log("background updated $image");
      _backgroundImage = image;
    });
    _metadataRepository.imageScaleFactor.listen((factor) {
      _logger.log("imageScale updated: $factor");
      _imageScaleFactor = factor;
    });

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
  Stream<Transition<MeasureEvent, MeasureState>> transformTransitions(Stream<Transition<MeasureEvent, MeasureState>> transitions) {
    return transitions.map((Transition<MeasureEvent, MeasureState> transition) {
      final state = transition.nextState;
      if (state is MeasureActiveState) {
        return Transition(currentState: transition.currentState,
            event: transition.event,
            nextState: MeasureActiveState(
                state.position,
                backgroundImage: _backgroundImage,
                imageScaleFactor: _imageScaleFactor,
            )
        );
      } else {
        return transition;
      }
    });
  }

  @override
  Stream<MeasureState> mapEventToState(MeasureEvent event) async* {
    if (event is MeasureDownEvent || event is MeasureMoveEvent) {
      yield MeasureActiveState(event.position);
    } else if (event is MeasureUpEvent) {
      yield MeasureInactiveState();
    }
  }
}
