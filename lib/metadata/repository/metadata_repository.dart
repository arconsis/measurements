import 'dart:ui';

import 'package:flutter/widgets.dart' as widget;
import 'package:measurements/util/logger.dart';
import 'package:rxdart/subjects.dart';


class MetadataRepository {
  final _logger = Logger(LogDistricts.METADATA_REPOSITORY);

  final _documentSize = BehaviorSubject<Size>();
  final _distanceCallback = BehaviorSubject<Function(List<double>)>();
  final _scale = BehaviorSubject<double>();
  final _zoomLevel = BehaviorSubject<double>.seeded(1.0);
  final _showDistance = BehaviorSubject<bool>();
  final _enableMeasure = BehaviorSubject<bool>.seeded(false);
  final _currentBackgroundImage = BehaviorSubject<Image>();
  final _orientation = BehaviorSubject<widget.Orientation>();
  final _viewWidth = BehaviorSubject<double>();
  final _transformationFactor = BehaviorSubject<double>();

  MetadataRepository() {
    _logger.log("Created repository");
  }

  Stream<bool> get measurement => _enableMeasure.stream;


  void registerStartedEvent(bool measure, bool showDistance, Function(List<double>) callback, double scale, double zoom, Size documentSize) {
    _enableMeasure.add(measure);
    _showDistance.add(showDistance);
    _distanceCallback.add(callback);
    _scale.add(scale);
    _zoomLevel.add(zoom);
    _documentSize.add(documentSize);
  }

  void registerBackgroundEvent(Image backgroundImage, double width) {
    _currentBackgroundImage.add(backgroundImage);
    _viewWidth.add(width);
  }

  void registerOrientationEvent(widget.Orientation orientation) {
    _orientation.add(orientation);
  }

  void dispose() {
    _documentSize.close();
    _distanceCallback.close();
    _scale.close();
    _zoomLevel.close();
    _showDistance.close();
    _enableMeasure.close();
    _currentBackgroundImage.close();
    _orientation.close();
    _viewWidth.close();
    _transformationFactor.close();
  }
}