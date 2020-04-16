import 'dart:ui';

import 'package:flutter/widgets.dart' as widget;
import 'package:rxdart/subjects.dart';

import '../../util/logger.dart';

class MetadataRepository {
  final logger = Logger(LogDistricts.METADATA_REPOSITORY);

  final documentSize = BehaviorSubject<Size>();
  final distanceCallback = BehaviorSubject<Function(List<double>)>();
  final scale = BehaviorSubject<double>();
  final zoomLevel = BehaviorSubject<double>.seeded(1.0);
  final showDistance = BehaviorSubject<bool>();
  final enableMeasure = BehaviorSubject<bool>.seeded(false);
  final currentBackgroundImage = BehaviorSubject<Image>();
  final orientation = BehaviorSubject<widget.Orientation>();
  final viewWidth = BehaviorSubject<double>();
  final transformationFactor = BehaviorSubject<double>();

  MetadataRepository() {
    logger.log("Created repository");
  }

  void dispose() {
    documentSize.close();
    distanceCallback.close();
    scale.close();
    zoomLevel.close();
    showDistance.close();
    enableMeasure.close();
    currentBackgroundImage.close();
    orientation.close();
    viewWidth.close();
    transformationFactor.close();
  }
}