/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'dart:ui';

import 'package:document_measure/document_measure.dart';
import 'package:document_measure/src/util/logger.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' as widget;
import 'package:rxdart/subjects.dart';

class MetadataRepository {
  final _logger = Logger(LogDistricts.METADATA_REPOSITORY);

  final _enableMeasure = BehaviorSubject<bool>.seeded(false);
  final _showDistance = BehaviorSubject<bool>();
  final _measurementInformation = BehaviorSubject<MeasurementInformation>();
  final _unitOfMeasurement = BehaviorSubject<LengthUnit>();
  final _magnificationRadius = BehaviorSubject<double>();
  final _controller = BehaviorSubject<MeasurementController>();

  final _imageScaleFactor = BehaviorSubject<double>();
  final _imageToDocumentFactor = BehaviorSubject<double>();
  final _currentBackgroundImage = BehaviorSubject<Image>();
  final _screenSize = BehaviorSubject<Size>();
  final _viewSize = BehaviorSubject<Size>();
  final _viewCenter = BehaviorSubject<Offset>();

  final _transformationFactor = BehaviorSubject<LengthUnit>();
  final _tolerance = BehaviorSubject<double>();

  final _zoomLevel = BehaviorSubject<double>.seeded(1.0);
  final _contentPosition = BehaviorSubject<Offset>();

  Rect _deleteRegion;

  MetadataRepository();

  Stream<bool> get measurement => _enableMeasure.stream;

  Stream<bool> get showDistances => _showDistance.stream;

  Stream<LengthUnit> get transformationFactor => _transformationFactor.stream;

  Stream<MeasurementController> get controller => _controller.stream;

  Stream<LengthUnit> get unitOfMeasurement => _unitOfMeasurement.stream;

  Stream<double> get zoom => _zoomLevel.stream;

  Stream<Offset> get backgroundPosition => _contentPosition.stream;

  Stream<double> get imageScaleFactor => _imageScaleFactor.stream;

  Stream<double> get imageToDocumentScaleFactor =>
      _imageToDocumentFactor.stream;

  Stream<Image> get backgroundImage => _currentBackgroundImage.stream;

  Stream<Offset> get viewCenter => _viewCenter.stream;

  Stream<double> get tolerance => _tolerance.stream;

  Stream<Size> get screenSize => _screenSize.stream;

  Stream<Size> get viewSize => _viewSize.stream;

  Stream<double> get magnificationCircleRadius => _magnificationRadius.stream;

  Future<double> get zoomFactorForLifeSize async {
    var pixelPerInch = await MethodChannel('documentmeasure')
        .invokeMethod('getPhysicalPixelsPerInch');
    var screenSize = _screenSize.value;

    if (screenSize == null) return 1;

    var information = _measurementInformation.value;

    if (isDocumentWidthAlignedWithScreenWidth(screenSize)) {
      return information.documentWidthInLengthUnits.convertToInch().value *
          pixelPerInch /
          (screenSize.width * information.scale * window.devicePixelRatio);
    } else {
      return information.documentHeightInLengthUnits.convertToInch().value *
          pixelPerInch /
          (screenSize.height * information.scale * window.devicePixelRatio);
    }
  }

  double get zoomFactorToFillScreen {
    if (_screenSize.value == null) return 1.0;

    if (isDocumentWidthAlignedWithScreenWidth(_screenSize.value)) {
      return _screenSize.value.height / _screenSize.value.width;
    } else {
      return _screenSize.value.width / _screenSize.value.height;
    }
  }

  void registerStartupValuesChange({
    @widget.required MeasurementInformation measurementInformation,
    @widget.required bool measure,
    @widget.required bool showDistance,
    @widget.required MagnificationStyle magnificationStyle,
    @widget.required MeasurementController controller,
  }) {
    _measurementInformation.value = measurementInformation;
    _unitOfMeasurement.value = measurementInformation.targetLengthUnit;
    _enableMeasure.value = measure;
    _showDistance.value = showDistance;
    _magnificationRadius.value = magnificationStyle.magnificationRadius +
        magnificationStyle.outerCircleThickness;
    _controller.value = controller;

    _updateTransformationFactor();
  }

  void registerBackgroundChange(Image backgroundImage, Size size) {
    _currentBackgroundImage.value = backgroundImage;
    _viewSize.value = size;
    _viewCenter.value = Offset(size.width / 2, size.height / 2);
    _imageScaleFactor.value = backgroundImage.width / size.width;

    _logger.log(
        'view size: ${_viewSize.value} view center: ${_viewCenter.value} image scale: ${_imageScaleFactor.value} image size $size');

    _updateImageToDocumentFactor(size);
    _updateTransformationFactor();
  }

  void registerResizing(Offset position, double zoom) {
    _logger.log('Offset: $position, zoom: $zoom');
    _contentPosition.value = position;
    _zoomLevel.value = zoom;
    _updateTransformationFactor();
  }

  void registerDeleteRegion(Offset position, Size size) => _deleteRegion =
      Rect.fromPoints(position, position + Offset(size.width, size.height));

  void registerScreenSize(Size size) {
    _screenSize.value = size;
    _logger.log('_screenSize: ${_screenSize.value}');
  }

  void registerMeasurementFunction(MeasurementFunction function) {
    _controller.value?.measurementFunction = function;
  }

  bool isInDeleteRegion(Offset position) => _deleteRegion.contains(position);

  bool isDocumentWidthAlignedWithScreenWidth(Size screenSize) {
    final documentAspectRatio = _getDocumentWidth() / _getDocumentHeight();
    final backgroundAspectRatio = screenSize.width / screenSize.height;

    return documentAspectRatio > backgroundAspectRatio;
  }

  void dispose() {
    _enableMeasure.close();
    _showDistance.close();
    _measurementInformation.close();
    _unitOfMeasurement.close();
    _magnificationRadius.close();
    _controller.close();

    _currentBackgroundImage.close();
    _imageScaleFactor.close();
    _imageToDocumentFactor.close();
    _screenSize.close();
    _viewSize.close();
    _viewCenter.close();

    _transformationFactor.close();
    _tolerance.close();

    _contentPosition.close();
    _zoomLevel.close();
  }

  double _getDocumentWidth() =>
      _measurementInformation.value.documentWidthInLengthUnits.value.toDouble();

  double _getDocumentHeight() =>
      _measurementInformation.value.documentHeightInLengthUnits.value
          .toDouble();

  void _updateImageToDocumentFactor(Size viewSize) {
    if (_screenSize.value == null) return;

    if (isDocumentWidthAlignedWithScreenWidth(viewSize)) {
      _imageToDocumentFactor.value = _getDocumentWidth() / viewSize.width;
    } else {
      _imageToDocumentFactor.value = _getDocumentHeight() / viewSize.height;
    }
  }

  void _updateTransformationFactor() async {
    if (_zoomLevel.hasValue &&
        _viewSize.hasValue &&
        _measurementInformation.hasValue) {
      var zoomLevel = _zoomLevel.value;
      var viewWidth = _viewSize.value.width;
      var measurementInfo = _measurementInformation.value;

      _transformationFactor.value =
          measurementInfo.documentToTargetFactor / measurementInfo.scale;
      _tolerance.value =
          measurementInfo.documentWidthInUnitOfMeasurement.value /
              (measurementInfo.scale * viewWidth) /
              zoomLevel;

      _controller.value?.tolerance = _tolerance.value;

      _logger.log('tolerance is: ${_transformationFactor.value}');
      _logger.log('updated transformationFactor');
    }
  }
}
