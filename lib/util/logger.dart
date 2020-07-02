///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

enum LogDistricts {
  MEASUREMENT_VIEW,
  METADATA_BLOC,
  METADATA_REPOSITORY,
  MEASURE_AREA,
  MEASURE_BLOC,
  POINTS_BLOC,
  MEASUREMENT_REPOSITORY,
}

class Logger {
  static final List<LogDistricts> _activeDistricts = [
//    LogDistricts.MEASUREMENT_VIEW,
//    LogDistricts.METADATA_BLOC,
//    LogDistricts.METADATA_REPOSITORY,
//
//    LogDistricts.MEASURE_AREA,
//    LogDistricts.MEASURE_BLOC,
//    LogDistricts.POINTS_BLOC,
//    LogDistricts.MEASUREMENT_REPOSITORY,
  ];

  final LogDistricts district;

  Logger(this.district);

  String _districtName(LogDistricts district) {
    return district.toString().split(".")[1];
  }

  log(String message) {
    if (_activeDistricts.contains(district)) {
      print("${DateTime.now()} measurements: (${_districtName(district)}) $message");
    }
  }
}
