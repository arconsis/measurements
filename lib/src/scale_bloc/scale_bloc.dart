/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'dart:async';

import 'package:document_measure/document_measure.dart';
import 'package:document_measure/src/metadata/repository/metadata_repository.dart';
import 'package:document_measure/src/util/logger.dart';
import 'package:document_measure/src/util/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'scale_event.dart';
import 'scale_state.dart';

class ScaleBloc extends Bloc<ScaleEvent, ScaleState>
    implements MeasurementFunction {
  final logger = Logger(LogDistricts.SCALE_BLOC);
  final List<StreamSubscription> subscriptions = [];

  final double _minScale = 1.0;
  final double _maxScale = 10.0;

  MetadataRepository _metadataRepository;

  Offset _translateStart;
  Offset _workingTranslate = Offset(0, 0);
  Offset _currentTranslate = Offset(0, 0);

  Size _screenSize;
  Size _viewSize;
  Offset _defaultOffset = Offset(0, 0);

  double _currentScale = 1.0;
  double _accumulatedScale = 1.0;
  double _doubleTapScale = 1.0;
  double _originalScale;

  bool _measure;

  ScaleBloc() : super(ScaleState(Offset(0, 0), 1.0, Matrix4.identity())) {
    _metadataRepository = GetIt.I<MetadataRepository>();

    subscriptions.add(_metadataRepository.measurement
        .listen((measure) => _measure = measure));
    subscriptions.add(_metadataRepository.viewSize.listen((size) {
      _viewSize = size;
      _updateDefaultOffset();
    }));
    subscriptions.add(_metadataRepository.screenSize.listen((size) async {
      _screenSize = size;
      _updateDefaultOffset();

      _doubleTapScale = _metadataRepository.zoomFactorToFillScreen;
      _originalScale = await _metadataRepository.zoomFactorForLifeSize;
    }));

    _metadataRepository.registerMeasurementFunction(this);
  }

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
        _workingTranslate = _currentTranslate.fitInto(
                _viewSize,
                _screenSize,
                _defaultOffset,
                event.position - _translateStart,
                0.01,
                _accumulatedScale) -
            _defaultOffset;
      } else {
        _accumulatedScale =
            (_currentScale * event.scale).fit(_minScale, _maxScale);
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
          ..scale(_originalScale),
      );
    } else if (event is ScaleResetEvent) {
      yield ScaleState(
        _defaultOffset,
        1.0,
        Matrix4.identity()
          ..translate(_defaultOffset.dx, _defaultOffset.dy)
          ..scale(1.0),
      );
    } else {
      yield ScaleState(
        offset,
        _accumulatedScale,
        Matrix4.identity()
          ..translate(offset.dx, offset.dy)
          ..scale(_accumulatedScale),
      );
    }
  }

  @override
  bool resetZoom() {
    add(ScaleResetEvent());
    return true;
  }

  @override
  bool zoomToLifeSize() {
    if (!(_originalScale?.isInBounds(_minScale, _maxScale) ?? false))
      return false;

    add(ScaleOriginalEvent());
    return true;
  }

  void _registerResizing() =>
      _metadataRepository.registerResizing(_getTranslate(), _accumulatedScale);

  Offset _getTranslate() => _defaultOffset + _workingTranslate;

  void _updateDefaultOffset() {
    if (_screenSize == null || _viewSize == null) return;

    _defaultOffset = Offset((_screenSize.width - _viewSize.width) / 2.0,
        (_screenSize.height - _viewSize.height) / 2.0);

    add(ScaleCenterUpdatedEvent());
    _registerResizing();
  }
}
