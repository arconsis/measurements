enum LogDistricts {
  BLOC,
  MEASUREMENT,
  MEASURE_AREA,
}

class Logger {
  static final List<LogDistricts> _activeDistricts = [LogDistricts.BLOC, LogDistricts.MEASURE_AREA];

  static log(String message, LogDistricts district) {
    if (_activeDistricts.contains(district)) {
      print("measurements: ($district) " + message);
    }
  }
}