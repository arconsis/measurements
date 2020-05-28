import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:measurements/measurements.dart';
import 'package:measurements/style/magnification_style.dart';
import 'package:measurements/util/logger.dart';
import 'package:rxdart/subjects.dart';


class MetadataRepository {
  final _logger = Logger(LogDistricts.METADATA_REPOSITORY);

  final _enableMeasure = BehaviorSubject<bool>.seeded(false);
  final _showDistance = BehaviorSubject<bool>();
  final _transformationFactor = BehaviorSubject<double>();
  final _imageScaleFactor = BehaviorSubject<double>();
  final _currentBackgroundImage = BehaviorSubject<ui.Image>();
  final _viewCenter = BehaviorSubject<Offset>();
  final _distanceCallback = BehaviorSubject<Function(List<double>)>();
  final _toleranceCallback = BehaviorSubject<Function(double)>();

  final _measurementInformation = BehaviorSubject<MeasurementInformation>();
  final _zoomLevel = BehaviorSubject<double>.seeded(1.0);
  final _viewSize = BehaviorSubject<Size>();
  final _magnificationRadius = BehaviorSubject<double>();

  final _viewWidthChangeFactor = BehaviorSubject<double>();

  MetadataRepository() {
    _logger.log("Created repository");
  }

  Stream<bool> get measurement => _enableMeasure.stream;

  Stream<bool> get showDistances => _showDistance.stream;

  Stream<double> get transformationFactor => _transformationFactor.stream;

  Stream<double> get imageScaleFactor => _imageScaleFactor.stream;

  Stream<ui.Image> get backgroundImage => _currentBackgroundImage.stream;

  Stream<Offset> get viewCenter => _viewCenter.stream;

  Stream<double> get tolerance => _transformationFactor.stream;

  Stream<Size> get viewSize => _viewSize.stream;

  Stream<double> get magnificationCircleRadius => _magnificationRadius.stream;

  Stream<double> get viewScaleFactor => _viewWidthChangeFactor.stream;

  Stream<Function(List<double>)> get callback => _distanceCallback.stream;


  void registerStartupValuesChange({
    @required MeasurementInformation measurementInformation,
    @required bool measure,
    @required bool showDistance,
    @required double zoom,
    @required MagnificationStyle magnificationStyle,
    @required Function(List<double>) callback,
    @required Function(double) toleranceCallback,
  }) {
    _measurementInformation.value = measurementInformation;
    _enableMeasure.value = measure;
    _showDistance.value = showDistance;
    _distanceCallback.value = callback;
    _toleranceCallback.value = toleranceCallback;
    _zoomLevel.value = zoom;
    _magnificationRadius.value = magnificationStyle.magnificationRadius + magnificationStyle.outerCircleThickness;

    _updateTransformationFactor();
  }

  void registerBackgroundChange(ui.Image backgroundImage, Size size) {
    _currentBackgroundImage.value = backgroundImage;
    _viewCenter.value = Offset(size.width / 2, size.height / 2);
    _imageScaleFactor.value = backgroundImage.width / size.width;

    if (_viewSize.value == null) {
      _viewSize.value = size;
    } else if (_viewSize.value.width != size.width) {
      _viewWidthChangeFactor.value = size.width / _viewSize.value.width;
      _viewSize.value = size;
    }

    _updateTransformationFactor();
  }

  void dispose() {
    _measurementInformation.close();
    _distanceCallback.close();
    _toleranceCallback.close();
    _zoomLevel.close();
    _showDistance.close();
    _enableMeasure.close();
    _currentBackgroundImage.close();
    _viewSize.close();
    _magnificationRadius.close();
    _viewCenter.close();
    _imageScaleFactor.close();
    _transformationFactor.close();
    _viewWidthChangeFactor.close();
  }

  void _updateTransformationFactor() async {
    if (_zoomLevel.hasValue && _viewSize.hasValue && _measurementInformation.hasValue) {
      double zoomLevel = _zoomLevel.value;
      double viewWidth = _viewSize.value.width;
      MeasurementInformation measurementInfo = _measurementInformation.value;

      _transformationFactor.value = measurementInfo.documentWidthInUnitOfMeasurement / (measurementInfo.scale * viewWidth * zoomLevel);

      _logger.log("tolerance is: ${_transformationFactor.value} ${measurementInfo.unitOfMeasurement}");
      _logger.log("updated transformationFactor");
    }
  }
}