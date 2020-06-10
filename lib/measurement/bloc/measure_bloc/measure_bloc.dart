///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:measurements/measurement/bloc/measure_bloc/measure_event.dart';
import 'package:measurements/measurement/bloc/measure_bloc/measure_state.dart';
import 'package:measurements/measurement/repository/measurement_repository.dart';
import 'package:measurements/metadata/repository/metadata_repository.dart';
import 'package:measurements/util/logger.dart';

class MeasureBloc extends Bloc<MeasureEvent, MeasureState> {
  final _logger = Logger(LogDistricts.MEASURE_BLOC);
  final _defaultMagnificationOffset = Offset(0, 40);

  MeasurementRepository _measureRepository;
  MetadataRepository _metadataRepository;

  Image _backgroundImage;
  double _imageScaleFactor;
  Size _viewSize;
  double _magnificationRadius;
  Offset _magnificationOffset;
  bool _measuring;

  MeasureBloc() {
    _measureRepository = GetIt.I<MeasurementRepository>();
    _metadataRepository = GetIt.I<MetadataRepository>();

    _metadataRepository.backgroundImage.listen((image) => _backgroundImage = image);
    _metadataRepository.imageScaleFactor.listen((factor) => _imageScaleFactor = factor);
    _metadataRepository.viewSize.listen((size) => _viewSize = size);
    _metadataRepository.measurement.listen((measuring) => _measuring = measuring);
    _metadataRepository.magnificationCircleRadius.listen((radius) {
      _magnificationRadius = radius;
      _magnificationOffset = Offset(_defaultMagnificationOffset.dx, _defaultMagnificationOffset.dy + radius);
    });
  }

  @override
  MeasureState get initialState => MeasureInactiveState();

  @override
  void onEvent(MeasureEvent event) {
    _logger.log("received event: $event");

    if (_measuring) {
      if (event is MeasureDownEvent) {
        _measureRepository.registerDownEvent(event.position);
      } else if (event is MeasureMoveEvent) {
        _measureRepository.registerMoveEvent(event.position);
      } else if (event is MeasureUpEvent) {
        _measureRepository.registerUpEvent(event.position);
      }
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
              state.magnificationOffset,
              absolutePosition: _measureRepository.convertIntoAbsolutePosition(state.position),
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
    if (!_measuring) return;

    if (event is MeasureDownEvent || event is MeasureMoveEvent) {
      Offset magnificationPosition = event.position - _magnificationOffset;

      if (magnificationGlassFitsWithoutModification(magnificationPosition)) {
        yield MeasureActiveState(event.position, _magnificationOffset);
      } else {
        Offset modifiedOffset = _magnificationOffset;

        if (event.position.dy < _magnificationOffset.dy + _magnificationRadius) {
          modifiedOffset = Offset(modifiedOffset.dx, -modifiedOffset.dy);
        }

        if (event.position.dx < _magnificationRadius) {
          modifiedOffset = Offset(event.position.dx - _magnificationRadius, modifiedOffset.dy);
        } else if (event.position.dx > _viewSize.width - _magnificationRadius) {
          modifiedOffset = Offset(_magnificationRadius - (_viewSize.width - event.position.dx), modifiedOffset.dy);
        }

        yield MeasureActiveState(event.position, modifiedOffset);
      }
    } else if (event is MeasureUpEvent) {
      yield MeasureInactiveState();
    }
  }

  bool magnificationGlassFitsWithoutModification(Offset magnificationPosition) =>
      magnificationPosition > Offset(_magnificationRadius, _magnificationRadius)
          && magnificationPosition < Offset(_viewSize.width - _magnificationRadius, _viewSize.height - _magnificationRadius);
}
