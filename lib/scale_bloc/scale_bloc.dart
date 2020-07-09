import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:measurements/measurement_controller.dart';
import 'package:measurements/metadata/repository/metadata_repository.dart';
import 'package:measurements/util/logger.dart';

import 'scale_event.dart';
import 'scale_state.dart';

///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

class ScaleBloc extends Bloc<ScaleEvent, ScaleState> implements MeasurementFunction {
  final logger = Logger(LogDistricts.SCALE_BLOC);
  final List<StreamSubscription> subscriptions = List();

  MetadataRepository _metadataRepository;

  Matrix4 _transformation = Matrix4.identity();

  Offset _translateStart;
  Offset _workingTranslate = Offset(0, 0);
  Offset _currentTranslate = Offset(0, 0);

  double _currentScale = 1.0;
  double _accumulatedScale = 1.0;
  double _doubleTapScale = 1.0;
  double _originalScale;

  bool _measure;

  ScaleBloc() {
    _metadataRepository = GetIt.I<MetadataRepository>();

    subscriptions.add(_metadataRepository.measurement.listen((measure) => _measure = measure));
    subscriptions.add(_metadataRepository.screenSize.listen((size) async {
      _doubleTapScale = _metadataRepository.zoomFactorToFillScreen;
      _originalScale = await _metadataRepository.zoomFactorForOriginalSize;
    }));

    _metadataRepository.registerMeasurementFunction(this);
  }

  @override
  ScaleState get initialState => ScaleState(Offset(0, 0), 1.0, _transformation);

  @override
  void onEvent(ScaleEvent event) {
    if (event is ScaleOriginalEvent && _originalScale != null) {
      _currentScale = _originalScale;
      _accumulatedScale = _currentScale;
    } else if (event is ScaleResetEvent) {
      _currentScale = 1.0;
      _accumulatedScale = _currentScale;
    }

    if (_measure) return;

    if (event is ScaleStartEvent) {
      _translateStart = event.position;

      _currentTranslate = _workingTranslate;
      _currentScale = _accumulatedScale;
    } else if (event is ScaleUpdateEvent) {
      if (event.scale == 1.0) {
        _workingTranslate = _currentTranslate + (event.position - _translateStart);
      } else {
        _accumulatedScale = _currentScale * event.scale;
      }

      _metadataRepository.registerResizing(_workingTranslate, _accumulatedScale);
    } else if (event is ScaleDoubleTapEvent) {
      if (_currentScale == 1.0) {
        _currentScale = _doubleTapScale;
      } else {
        _currentScale = 1.0;
      }

      _currentTranslate = Offset(0, 0);

      _accumulatedScale = _currentScale;
      _workingTranslate = _currentTranslate;
    }

    super.onEvent(event);
  }

  @override
  Future<void> close() {
    subscriptions.forEach((subscription) => subscription.cancel());

    return super.close();
  }

  @override
  Stream<ScaleState> mapEventToState(ScaleEvent event) async* {
    if (event is ScaleOriginalEvent) {
      yield ScaleState(
          Offset(_workingTranslate.dx, _workingTranslate.dy),
          _originalScale,
          Matrix4.identity()
            ..translate(_workingTranslate.dx, _workingTranslate.dy)
            ..scale(_originalScale));
    } else if (event is ScaleResetEvent) {
      yield ScaleState(
          Offset(_workingTranslate.dx, _workingTranslate.dy),
          1.0,
          Matrix4.identity()
            ..translate(_workingTranslate.dx, _workingTranslate.dy)
            ..scale(1.0));
    } else {
      yield ScaleState(
          Offset(_workingTranslate.dx, _workingTranslate.dy),
          _accumulatedScale,
          Matrix4.identity()
            ..translate(_workingTranslate.dx, _workingTranslate.dy)
            ..scale(_accumulatedScale));
    }
  }

  @override
  void resetZoom() {
    add(ScaleResetEvent());
  }

  @override
  void zoomToOriginal() {
    add(ScaleOriginalEvent());
  }
}
