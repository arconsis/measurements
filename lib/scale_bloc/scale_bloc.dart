import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:measurements/measurement_controller.dart';
import 'package:measurements/metadata/repository/metadata_repository.dart';
import 'package:measurements/scale_bloc/scale_event.dart';
import 'package:measurements/scale_bloc/scale_state.dart';

///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

class GestureBloc extends Bloc<GestureEvent, GestureState> implements MeasurementFunction  {
  final List<StreamSubscription> subscriptions = List();

  MetadataRepository _metadataRepository;

  Matrix4 _transformation = Matrix4.identity();

  Offset _translateStart;
  Offset _workingTranslate = Offset(0, 0);
  Offset _currentTranslate = Offset(0, 0);

  double _currentScale = 1.0;
  double _accumulatedScale = 1.0;

  bool _measure;

  GestureBloc() {
    _metadataRepository = GetIt.I<MetadataRepository>();

    subscriptions.add(_metadataRepository.measurement.listen((measure) => _measure = measure));
  }

  @override
  GestureState get initialState => GestureState(Offset(0, 0), 1.0, _transformation);

  @override
  void onEvent(GestureEvent event) {
    if (_measure) return;

    if (event is GestureScaleStartEvent) {
      _translateStart = event.position;

      _currentTranslate = _workingTranslate;
      _currentScale = _accumulatedScale;
    } else if (event is GestureScaleUpdateEvent) {
      if (event.scale == 1.0) {
        _workingTranslate = _currentTranslate + (event.position - _translateStart);
      } else {
        _accumulatedScale = _currentScale * event.scale;
      }

      _metadataRepository.registerResizing(_workingTranslate, _accumulatedScale);
    }

    super.onEvent(event);
  }

  @override
  Stream<GestureState> mapEventToState(GestureEvent event) async* {
    if (_measure) return;

    if (event is GestureScaleUpdateEvent) {
      yield GestureState(
          Offset(0, 0),
          _accumulatedScale,
          Matrix4.identity()
            ..translate(_workingTranslate.dx, _workingTranslate.dy)
            ..scale(_accumulatedScale));
    }
  }

  @override
  void resetZoom() {
    // TODO: implement resetZoom
  }

  @override
  void zoomToOriginal() {
    // TODO: implement zoomToOriginal
  }
}
