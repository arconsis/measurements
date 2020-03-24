enum LogDistricts {
  BLOC,
  MEASUREMENT,
  MEASURE_AREA,
}

class Logger {
  static final List<LogDistricts> _activeDistricts = [LogDistricts.BLOC, LogDistricts.MEASURE_AREA];

  final LogDistricts district;

  Logger(this.district);

  log(String message) {
    if (_activeDistricts.contains(district)) {
      print("measurements: ($district) " + message);
    }
  }
}