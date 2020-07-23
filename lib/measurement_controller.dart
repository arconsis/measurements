/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

/// Interface to offer zoom functionality.
abstract class MeasurementFunction {
  /// Scales the document such that it appears in a scale of 1:1 on the device screen.
  /// Only works, when the resulting zoom factor is not too large (performance and other issues would arise).
  bool zoomToLifeSize();

  /// When zoomed in this will reset the zoom to 1.
  bool resetZoom();
}

/// Simple class that offers the list of distances between the set points and the tolerance under with the distances were calculated.
class MeasurementValues extends Equatable {
  /// Distances in order of placed points.
  final List<double> distances;

  /// Tolerance due to the size of one individual pixel.
  final double tolerance;

  MeasurementValues(this.distances, this.tolerance);

  @override
  List<Object> get props => [distances, tolerance];
}

/// This controller offers the interaction with the displayed content for zooming in and out.
/// You can get the latest distances and tolerance directly
class MeasurementController {
  final BehaviorSubject<MeasurementValues> _currentValues = BehaviorSubject();
  MeasurementFunction _function;

  MeasurementController();

  @protected
  set measurementFunction(MeasurementFunction function) => _function = function;

  Stream<MeasurementValues> get measurements => _currentValues.stream;

  List<double> get distances => _currentValues.value?.distances;

  @protected
  set distances(List<double> distances) {
    if (_currentValues.value?.distances == distances) {
      return;
    }

    _currentValues.value = MeasurementValues(distances, tolerance);
  }

  double get tolerance => _currentValues.value?.tolerance;

  @protected
  set tolerance(double tolerance) {
    if (_currentValues.value?.tolerance == tolerance) {
      return;
    }

    _currentValues.value = MeasurementValues(distances, tolerance);
  }

  bool zoomToLifeSize() => _function?.zoomToLifeSize();

  bool resetZoom() => _function?.resetZoom();

  void close() {
    _currentValues.close();
  }
}
