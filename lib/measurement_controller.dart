import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///


abstract class MeasurementFunction {
  void zoomToOriginal();

  void resetZoom();
}

class MeasurementValues extends Equatable {
  final List<double> distances;
  final double tolerance;

  MeasurementValues(this.distances, this.tolerance);

  @override
  List<Object> get props => [distances, tolerance];
}

class MeasurementController {
  final BehaviorSubject<MeasurementValues> _currentValues = BehaviorSubject();
  MeasurementFunction _function;

  MeasurementController();

  set measurementFunction(MeasurementFunction function) => _function = function;

  Stream<MeasurementValues> get measurements => _currentValues.stream;

  List<double> get distances => _currentValues.value?.distances;

  set distances(List<double> distances) {
    if (_currentValues.value?.distances == distances) {
      return;
    }

    _currentValues.value = MeasurementValues(distances, tolerance);
  }

  double get tolerance => _currentValues.value?.tolerance;

  set tolerance(double tolerance) {
    if (_currentValues.value?.tolerance == tolerance) {
      return;
    }

    _currentValues.value = MeasurementValues(distances, tolerance);
  }

  void zoomToOriginalSize() => _function?.zoomToOriginal();

  void resetZoom() => _function?.resetZoom();

  void close() {
    _currentValues.close();
  }
}