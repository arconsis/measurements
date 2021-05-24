/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
import 'dart:async';
import 'dart:ui';

import 'package:document_measure/src/di/get_it.dart';
import 'package:document_measure/src/input_bloc/input_bloc.dart';
import 'package:document_measure/src/input_bloc/input_state.dart';
import 'package:document_measure/src/measurement/repository/measurement_repository.dart';
import 'package:document_measure/src/metadata/repository/metadata_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../input_bloc/input_bloc.dart';
import '../../../metadata/repository/metadata_repository.dart';
import '../../repository/measurement_repository.dart';
import 'magnification_event.dart';
import 'magnification_state.dart';

class MagnificationBloc extends Bloc<MagnificationEvent, MagnificationState> {
  final _defaultMagnificationOffset = Offset(0, 40);
  final List<StreamSubscription> _streamSubscriptions = [];

  final InputBloc inputBloc;
  final MeasurementRepository _measureRepository;
  final MetadataRepository _metadataRepository;

  Image? _backgroundImage;
  double? _imageScaleFactor;
  Size? _viewSize;
  double? _magnificationRadius;
  Offset? _magnificationOffset;

  factory MagnificationBloc.create(InputBloc inputBloc) => MagnificationBloc(inputBloc, get<MeasurementRepository>(), get<MetadataRepository>());

  MagnificationBloc(this.inputBloc, this._measureRepository, this._metadataRepository) : super(MagnificationInactiveState()) {
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
              absolutePosition: _measureRepository.convertIntoDocumentLocalTopLeftPosition(state.position),
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

  Offset _getSafeMagnificationOffset() => (_magnificationOffset ?? Offset(0, 0));

  double _getSafeMagnificationRadius() => (_magnificationRadius ?? 0.0);

  Size _getSafeViewSize() => (_viewSize ?? Size(0, 0));

  MagnificationState _mapMagnificationShowToState(MagnificationShowEvent event) {
    final magnificationOffset = _getSafeMagnificationOffset();
    final magnificationRadius = _getSafeMagnificationRadius();
    final viewSize = _getSafeViewSize();

    final magnificationPosition = event.position - magnificationOffset;

    if (_magnificationGlassFitsWithoutModification(magnificationPosition)) {
      return MagnificationActiveState(event.position, magnificationOffset);
    } else {
      var modifiedOffset = magnificationOffset;

      if (event.position.dy < magnificationOffset.dy + magnificationRadius) {
        modifiedOffset = Offset(modifiedOffset.dx, -modifiedOffset.dy);
      }

      if (event.position.dx < magnificationRadius) {
        modifiedOffset = Offset(event.position.dx - magnificationRadius, modifiedOffset.dy);
      } else if (event.position.dx > viewSize.width - magnificationRadius) {
        modifiedOffset = Offset(magnificationRadius - (viewSize.width - event.position.dx), modifiedOffset.dy);
      }

      return MagnificationActiveState(event.position, modifiedOffset);
    }
  }

  bool _magnificationGlassFitsWithoutModification(Offset magnificationPosition) {
    final magnificationRadius = _getSafeMagnificationRadius();
    final viewSize = _getSafeViewSize();

    return magnificationPosition > Offset(magnificationRadius, magnificationRadius) &&
        magnificationPosition < Offset(viewSize.width - magnificationRadius, viewSize.height - magnificationRadius);
  }
}
