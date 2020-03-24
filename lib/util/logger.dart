enum LogDistricts {
  BLOC,
  MEASUREMENT,
  MEASURE_AREA,
  DISTANCE_PAINTER,
}

class Logger {
  static final List<LogDistricts> _activeDistricts = [
    LogDistricts.DISTANCE_PAINTER
  ];

  final LogDistricts district;

  Logger(this.district);

  log(String message) {
    if (_activeDistricts.contains(district)) {
      print("measurements: ($district) " + message);
    }
  }
}