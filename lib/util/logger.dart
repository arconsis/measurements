enum LogDistricts {
  BLOC,
  MEASUREMENT,
  MEASURE_AREA,
  DISTANCE_PAINTER,
  MEASURE_PAINTER,
  MAGNIFYING_PAINTER,
  POINTER_HANDLER,
  METADATA_REPOSITORY,
  MEASUREMENT_REPOSITORY,
}

class Logger {
  static final List<LogDistricts> _activeDistricts = [
//    LogDistricts.MEASURE_AREA,
//    LogDistricts.POINTER_HANDLER,
//    LogDistricts.MEASUREMENT,
//    LogDistricts.MEASURE_PAINTER,
//    LogDistricts.DISTANCE_PAINTER,
//    LogDistricts.MAGNIFYING_PAINTER,
//    LogDistricts.BLOC,
    LogDistricts.METADATA_REPOSITORY,
    LogDistricts.MEASUREMENT_REPOSITORY,
  ];

  final LogDistricts district;

  Logger(this.district);

  String _districtName(LogDistricts district) {
    return district.toString().split(".")[1];
  }

  log(String message) {
    if (_activeDistricts.contains(district)) {
      print("measurements: (${_districtName(district)}) $message");
    }
  }
}