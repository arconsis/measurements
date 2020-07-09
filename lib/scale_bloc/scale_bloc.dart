import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:measurements/measurement_controller.dart';
import 'package:measurements/metadata/repository/metadata_repository.dart';
import 'package:measurements/util/logger.dart';
import 'package:measurements/util/utils.dart';

import 'scale_event.dart';
import 'scale_state.dart';

///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

class ScaleBloc extends Bloc<ScaleEvent, ScaleState> implements MeasurementFunction {
  final logger = Logger(LogDistricts.SCALE_BLOC);
  final List<StreamSubscription> subscriptions = List();

  final double _minScale = 1.0;
  final double _maxScale = 10.0;

  MetadataRepository _metadataRepository;

  Matrix4 _transformation = Matrix4.identity();

  Offset _translateStart;
  Offset _workingTranslate = Offset(0, 0);
  Offset _currentTranslate = Offset(0, 0);

  Size _screenSize;
  Size _viewSize;
  Offset defaultOffset = Offset(0, 0);

  double _currentScale = 1.0;
  double _accumulatedScale = 1.0;
  double _doubleTapScale = 1.0;
  double _originalScale;

  bool _measure;

  ScaleBloc() {
    _metadataRepository = GetIt.I<MetadataRepository>();

    subscriptions.add(_metadataRepository.measurement.listen((measure) => _measure = measure));
    subscriptions.add(_metadataRepository.viewSize.listen((size) {
      _viewSize = size;
      _updateDefaultOffset();
    }));
    subscriptions.add(_metadataRepository.screenSize.listen((size) async {
      _screenSize = size;
      _updateDefaultOffset();

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
      _registerResizing();
    } else if (event is ScaleResetEvent) {
      _currentScale = 1.0;
      _accumulatedScale = _currentScale;
      _registerResizing();
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
        _accumulatedScale = (_currentScale * event.scale).fit(_minScale, _maxScale);
      }
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

    _registerResizing();
    super.onEvent(event);
  }

  @override
  Future<void> close() {
    subscriptions.forEach((subscription) => subscription.cancel());

    return super.close();
  }

  @override
  Stream<ScaleState> mapEventToState(ScaleEvent event) async* {
    final offset = _getTranslate();

    if (event is ScaleOriginalEvent) {
      yield ScaleState(
          offset,
          _originalScale,
          Matrix4.identity()
            ..translate(offset.dx, offset.dy)
            ..scale(_originalScale));
    } else if (event is ScaleResetEvent) {
      yield ScaleState(
          defaultOffset,
          1.0,
          Matrix4.identity()
            ..translate(defaultOffset.dx, defaultOffset.dy)
            ..scale(1.0));
    } else {
      yield ScaleState(
          offset,
          _accumulatedScale,
          Matrix4.identity()
            ..translate(offset.dx, offset.dy)
            ..scale(_accumulatedScale));
    }
  }

  @override
  bool resetZoom() {
    add(ScaleResetEvent());
    return true;
  }

  @override
  bool zoomToOriginal() {
    if (!_originalScale.isInBounds(_minScale, _maxScale)) return false;

    add(ScaleOriginalEvent());
    return true;
  }

  void _registerResizing() => _metadataRepository.registerResizing(_getTranslate(), _accumulatedScale);

  Offset _getTranslate() => defaultOffset + _workingTranslate;

  void _updateDefaultOffset() {
    if (_screenSize == null || _viewSize == null) return;

    if (_metadataRepository.isDocumentWidthAlignedWithScreenWidth(_screenSize)) {
      defaultOffset = Offset(0, (_screenSize.height - _viewSize.height) / 2.0);
    } else {
      defaultOffset = Offset((_screenSize.width - _viewSize.width) / 2.0, 0);
    }

    add(ScaleCenterUpdatedEvent());
    _registerResizing();
  }
}
