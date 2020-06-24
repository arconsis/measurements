///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:measurements/measurements.dart';
import 'package:measurements/style/magnification_style.dart';
import 'package:measurements/util/logger.dart';
import 'package:rxdart/subjects.dart';


class MetadataRepository {
  final _logger = Logger(LogDistricts.METADATA_REPOSITORY);

  final _enableMeasure = BehaviorSubject<bool>.seeded(false);
  final _showDistance = BehaviorSubject<bool>();
  final _measurementInformation = BehaviorSubject<MeasurementInformation>();
  final _unitOfMeasurement = BehaviorSubject<LengthUnit>();
  final _magnificationRadius = BehaviorSubject<double>();
  final _orientation = BehaviorSubject<Orientation>();
  final _controller = BehaviorSubject<MeasurementController>();

  final _imageScaleFactor = BehaviorSubject<double>();
  final _imageToDocumentFactor = BehaviorSubject<double>();
  final _currentBackgroundImage = BehaviorSubject<ui.Image>();
  final _viewSize = BehaviorSubject<Size>();
  final _viewCenter = BehaviorSubject<Offset>();

  final _transformationFactor = BehaviorSubject<LengthUnit>();
  final _tolerance = BehaviorSubject<double>();

  final _zoomLevel = BehaviorSubject<double>.seeded(1.0);
  final _contentPosition = BehaviorSubject<Offset>();

  MetadataRepository();

  Stream<bool> get measurement => _enableMeasure.stream;

  Stream<bool> get showDistances => _showDistance.stream;

  Stream<Orientation> get orientation => _orientation.stream;

  Stream<LengthUnit> get transformationFactor => _transformationFactor.stream;

  Stream<MeasurementController> get controller => _controller.stream;

  Stream<LengthUnit> get unitOfMeasurement => _unitOfMeasurement.stream;

  Stream<double> get zoom => _zoomLevel.stream;

  Stream<Offset> get backgroundPosition => _contentPosition.stream;

  Stream<double> get imageScaleFactor => _imageScaleFactor.stream;

  Stream<double> get imageToDocumentScaleFactor => _imageToDocumentFactor.stream;

  Stream<ui.Image> get backgroundImage => _currentBackgroundImage.stream;

  Stream<Offset> get viewCenter => _viewCenter.stream;

  Stream<double> get tolerance => _tolerance.stream;

  Stream<Size> get viewSize => _viewSize.stream;

  Stream<double> get magnificationCircleRadius => _magnificationRadius.stream;


  void registerStartupValuesChange({
    @required MeasurementInformation measurementInformation,
    @required bool measure,
    @required bool showDistance,
    @required MagnificationStyle magnificationStyle,
    @required MeasurementController controller,
  }) {
    _measurementInformation.value = measurementInformation;
    _unitOfMeasurement.value = measurementInformation.targetLengthUnit;
    _enableMeasure.value = measure;
    _showDistance.value = showDistance;
    _magnificationRadius.value = magnificationStyle.magnificationRadius + magnificationStyle.outerCircleThickness;
    _controller.value = controller;

    _updateTransformationFactor();
  }

  void registerBackgroundChange(ui.Image backgroundImage, Size size) {
    _currentBackgroundImage.value = backgroundImage;
    _viewSize.value = size;
    _viewCenter.value = Offset(size.width / 2, size.height / 2);
    _imageScaleFactor.value = backgroundImage.width / size.width;

    _logger.log("view size: ${_viewSize.value} view center: ${_viewCenter.value} image scale: ${_imageScaleFactor.value} image size $size");

    _updateImageToDocumentFactor(size);
    _updateTransformationFactor();
  }

  void _updateImageToDocumentFactor(Size viewSize) {
    final documentWidth = _measurementInformation.value.documentWidthInLengthUnits.value.toDouble();
    final documentHeight = _measurementInformation.value.documentHeightInLengthUnits.value.toDouble();
    final documentAspectRatio = documentWidth / documentHeight;
    final backgroundAspectRatio = viewSize.width / viewSize.height;

    if (documentAspectRatio > backgroundAspectRatio) { // width of document is width of background
      _imageToDocumentFactor.value = documentWidth / viewSize.width;
    } else { // height of document is height of background
      _imageToDocumentFactor.value = documentHeight / viewSize.height;
    }
  }

  void registerOrientation(Orientation orientation) {
    _orientation.value = orientation;
  }

  void registerResizing(Offset position, double zoom) {
    _logger.log("Offset: $position, zoom: $zoom");
    _contentPosition.value = position;
    _zoomLevel.value = zoom;
    _updateTransformationFactor();
  }

  void dispose() {
    _enableMeasure.close();
    _showDistance.close();
    _measurementInformation.close();
    _unitOfMeasurement.close();
    _magnificationRadius.close();
    _orientation.close();
    _controller.close();

    _currentBackgroundImage.close();
    _imageScaleFactor.close();
    _imageToDocumentFactor.close();
    _viewSize.close();
    _viewCenter.close();

    _transformationFactor.close();
    _tolerance.close();

    _contentPosition.close();
    _zoomLevel.close();
  }

  void _updateTransformationFactor() async {
    if (_zoomLevel.hasValue && _viewSize.hasValue && _measurementInformation.hasValue) {
      double zoomLevel = _zoomLevel.value;
      double viewWidth = _viewSize.value.width;
      MeasurementInformation measurementInfo = _measurementInformation.value;

      _transformationFactor.value = measurementInfo.documentToTargetFactor / measurementInfo.scale;
      _tolerance.value = measurementInfo.documentWidthInUnitOfMeasurement.value / (measurementInfo.scale * viewWidth) / zoomLevel;

      _controller.value?.tolerance = _tolerance.value;

      _logger.log("tolerance is: ${_transformationFactor.value}");
      _logger.log("updated transformationFactor");
    }
  }

  Future<double> get zoomFactorForOriginalSize async {
    double pixelPerInch = await MethodChannel("measurements").invokeMethod("getPhysicalPixelsPerInch");
    double screenWidth = _viewSize.value?.width ?? 0;

    if (screenWidth == 0) return 1;

    MeasurementInformation information = _measurementInformation.value;

    return information.documentWidthInLengthUnits
        .convertToInch()
        .value * pixelPerInch / (screenWidth * information.scale * window.devicePixelRatio);
  }
}