enum LogDistricts {
  BLOC,
  MEASUREMENT,
  MEASURE_AREA,
  DISTANCE_PAINTER,
  MEASURE_PAINTER,
}

class Logger {
  static final List<LogDistricts> _activeDistricts = [
//    LogDistricts.MEASURE_AREA,
//    LogDistricts.MEASUREMENT,
//    LogDistricts.MEASURE_PAINTER,
//    LogDistricts.DISTANCE_PAINTER,
//    LogDistricts.BLOC
  ];

  final LogDistricts district;

  Logger(this.district);

  log(String message) {
    if (_activeDistricts.contains(district)) {
      print("measurements: ($district) " + message);
    }
  }
}