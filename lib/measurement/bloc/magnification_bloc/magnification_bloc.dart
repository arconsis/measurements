import 'dart:async';

///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:measurements/input_state/input_bloc.dart';
import 'package:measurements/input_state/input_state.dart';
import 'package:measurements/measurement/repository/measurement_repository.dart';
import 'package:measurements/metadata/repository/metadata_repository.dart';
import 'package:measurements/util/logger.dart';

import 'magnification_event.dart';
import 'magnification_state.dart';

class MagnificationBloc extends Bloc<MagnificationEvent, MagnificationState> {
  final _logger = Logger(LogDistricts.MEASURE_BLOC);
  final _defaultMagnificationOffset = Offset(0, 40);
  final InputBloc inputBloc;
  final List<StreamSubscription> _streamSubscriptions = List();

  MeasurementRepository _measureRepository;
  MetadataRepository _metadataRepository;

  Image _backgroundImage;
  double _imageScaleFactor;
  Size _viewSize;
  double _magnificationRadius;
  Offset _magnificationOffset;

  MagnificationBloc(this.inputBloc) {
    _measureRepository = GetIt.I<MeasurementRepository>();
    _metadataRepository = GetIt.I<MetadataRepository>();

    _streamSubscriptions.add(_metadataRepository.backgroundImage.listen((image) => _backgroundImage = image));
    _streamSubscriptions.add(_metadataRepository.imageScaleFactor.listen((factor) => _imageScaleFactor = factor));
    _streamSubscriptions.add(_metadataRepository.viewSize.listen((size) => _viewSize = size));
    _streamSubscriptions.add(_metadataRepository.magnificationCircleRadius.listen((radius) {
      _magnificationRadius = radius;
      _magnificationOffset = Offset(_defaultMagnificationOffset.dx, _defaultMagnificationOffset.dy + radius);
    }));

    _streamSubscriptions.add(inputBloc.listen((state) {
      if (state is InputStandardState) {
        add(MagnificationShowEvent(state.position));
      } else if (state is InputEmptyState) {
        add(MagnificationHideEvent());
      } else if (state is InputDeleteRegionState) {
        add(MagnificationHideEvent());
      } else if (state is InputEndedState) {
        add(MagnificationHideEvent());
      } else if (state is InputDeleteState) {
        add(MagnificationHideEvent());
      }
    }));
  }

  @override
  MagnificationState get initialState => MagnificationInactiveState();

  @override
  Stream<Transition<MagnificationEvent, MagnificationState>> transformTransitions(Stream<Transition<MagnificationEvent, MagnificationState>> transitions) {
    return transitions.map((Transition<MagnificationEvent, MagnificationState> transition) {
      final state = transition.nextState;
      if (state is MagnificationActiveState) {
        return Transition(
            currentState: transition.currentState,
            event: transition.event,
            nextState: MagnificationActiveState(
              state.position,
              state.magnificationOffset,
              absolutePosition: _measureRepository.convertIntoAbsoluteTopLeftPosition(state.position),
              backgroundImage: _backgroundImage,
              imageScaleFactor: _imageScaleFactor,
            ));
      } else {
        return transition;
      }
    });
  }

  @override
  Stream<MagnificationState> mapEventToState(MagnificationEvent event) async* {
    if (event is MagnificationShowEvent) {
      yield _mapMagnificationShowToState(event);
    } else if (event is MagnificationHideEvent) {
      yield MagnificationInactiveState();
    }
  }

  @override
  Future<void> close() {
    _streamSubscriptions.forEach((subscription) => subscription.cancel());
    return super.close();
  }

  MagnificationState _mapMagnificationShowToState(MagnificationShowEvent event) {
    Offset magnificationPosition = event.position - _magnificationOffset;

    if (_magnificationGlassFitsWithoutModification(magnificationPosition)) {
      return MagnificationActiveState(event.position, _magnificationOffset);
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

      return MagnificationActiveState(event.position, modifiedOffset);
    }
  }

  bool _magnificationGlassFitsWithoutModification(Offset magnificationPosition) =>
      magnificationPosition > Offset(_magnificationRadius, _magnificationRadius) && magnificationPosition < Offset(_viewSize.width - _magnificationRadius, _viewSize.height - _magnificationRadius);
}
