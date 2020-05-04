import 'dart:ui';

import 'package:measurements/util/logger.dart';
import 'package:rxdart/subjects.dart';


class MetadataRepository {
  final _logger = Logger(LogDistricts.METADATA_REPOSITORY);

  final _enableMeasure = BehaviorSubject<bool>.seeded(false);
  final _showDistance = BehaviorSubject<bool>();
  final _transformationFactor = BehaviorSubject<double>();
  final _imageScaleFactor = BehaviorSubject<double>();
  final _currentBackgroundImage = BehaviorSubject<Image>();
  final _viewCenter = BehaviorSubject<Offset>();
  final _distanceCallback = BehaviorSubject<Function(List<double>)>();

  final _documentSize = BehaviorSubject<Size>();
  final _scale = BehaviorSubject<double>();
  final _zoomLevel = BehaviorSubject<double>.seeded(1.0);
  final _viewWidth = BehaviorSubject<double>();

  final _viewWidthChangeFactor = BehaviorSubject<double>();

  MetadataRepository() {
    _logger.log("Created repository");
  }

  Stream<bool> get measurement => _enableMeasure.stream;

  Stream<bool> get showDistances => _showDistance.stream;

  Stream<double> get transformationFactor => _transformationFactor.stream;

  Stream<double> get imageScaleFactor => _imageScaleFactor.stream;

  Stream<Image> get backgroundImage => _currentBackgroundImage.stream;

  Stream<Offset> get viewCenter => _viewCenter.stream;

  Stream<double> get viewScaleFactor => _viewWidthChangeFactor.stream;

  Stream<Function(List<double>)> get callback => _distanceCallback.stream;


  void registerStartupValuesChange(bool measure, bool showDistance, Function(List<double>) callback, double scale, double zoom, Size documentSize) {
    _enableMeasure.value = measure;
    _showDistance.value = showDistance;
    _distanceCallback.value = callback;
    _scale.value = scale;
    _zoomLevel.value = zoom;
    _documentSize.value = documentSize;

    _updateTransformationFactor();
  }

  void registerBackgroundChange(Image backgroundImage, Size size) {
    _currentBackgroundImage.value = backgroundImage;
    _viewCenter.value = Offset(size.width / 2, size.height / 2);
    _imageScaleFactor.value = backgroundImage.width / size.width;

    if (_viewWidth.value == null) {
      _viewWidth.value = size.width;
    } else if (_viewWidth.value != size.width) {
      _viewWidthChangeFactor.value = size.width / _viewWidth.value;
      _viewWidth.value = size.width;
    }

    _updateTransformationFactor();
  }

  void dispose() {
    _documentSize.close();
    _distanceCallback.close();
    _scale.close();
    _zoomLevel.close();
    _showDistance.close();
    _enableMeasure.close();
    _currentBackgroundImage.close();
    _viewWidth.close();
    _viewCenter.close();
    _imageScaleFactor.close();
    _transformationFactor.close();
    _viewWidthChangeFactor.close();
  }

  void _updateTransformationFactor() async {
    if (_scale.hasValue && _zoomLevel.hasValue && _viewWidth.hasValue && _documentSize.hasValue) {
      double scale = _scale.value;
      double zoomLevel = _zoomLevel.value;
      double viewWidth = _viewWidth.value;
      double documentWidth = _documentSize.value.width;

      _transformationFactor.value = documentWidth / (scale * viewWidth * zoomLevel);

      _logger.log("updated transformationFactor");
    }
  }
}