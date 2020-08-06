/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'package:equatable/equatable.dart';
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

/// A controller that offers interaction with the displayed content for zooming in or out and retrieving the measured distances.
///
/// You can get the latest distances and tolerance directly by calling [distances] and [tolerance] respectively
/// or listen to the [MeasurementValues] stream via
/// ```dart
/// measurementController.measurements.listen((value) => ...);
/// ```
class MeasurementController {
  final BehaviorSubject<MeasurementValues> _currentValues = BehaviorSubject();
  MeasurementFunction _function;

  MeasurementController();

  /// Only for internal use. Don't use it, as that will break the update of distances.
  set measurementFunction(MeasurementFunction function) => _function = function;

  /// The stream of measurements the user takes.
  /// They will be in the selected unit of measurement in [MeasurementView].
  Stream<MeasurementValues> get measurements => _currentValues.stream;

  /// Returns the latest distances.
  List<double> get distances => _currentValues.value?.distances;

  /// Only for internal use. Using it will return [distances] back to you in the [measurements] [Stream].
  set distances(List<double> distances) {
    if (_currentValues.value?.distances == distances) {
      return;
    }

    _currentValues.value = MeasurementValues(distances, tolerance);
  }

  /// Return the current tolerance.
  /// This might change as the user zooms in and out.
  double get tolerance => _currentValues.value?.tolerance;

  /// Only for internal use. Using it will return [tolerance] back to you in the [measurements] [Stream].
  set tolerance(double tolerance) {
    if (_currentValues.value?.tolerance == tolerance) {
      return;
    }

    _currentValues.value = MeasurementValues(distances, tolerance);
  }

  /// Zoom the content to life-size if possible.
  /// When the resulting zoom would be too large the call will be ignored to avoid performance issues and other problems.
  bool zoomToLifeSize() => _function?.zoomToLifeSize();

  /// Reset the zoom back to 1, which will fit the content into the view.
  bool resetZoom() => _function?.resetZoom();

  void close() {
    _currentValues.close();
  }
}
