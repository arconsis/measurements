import 'dart:ui';

import 'package:get_it/get_it.dart';
import 'package:measurements/metadata/repository/metadata_repository.dart';
import 'package:rxdart/rxdart.dart';

import '../../util/logger.dart';

class MeasurementRepository {
  final logger = Logger(LogDistricts.MEASUREMENT_REPOSITORY);

  final points = BehaviorSubject<List<Offset>>();
  final distances = BehaviorSubject<List<double>>();
  final showDistances = BehaviorSubject<bool>.seeded(false);

  double transformationFactor = 0.0;

  MeasurementRepository() {
    logger.log("Created Repository");

    GetIt.I.isReady<MetadataRepository>()
        .then((_) =>
        GetIt
            .I<MetadataRepository>()
            .transformationFactor
            .listen((double factor) {

        }));
  }

  void dispose() {
    points.close();
    distances.close();
    showDistances.close();
  }

  void registerDownEvent(Offset position) {}

  void registerMoveEvent(Offset position) {}

  void registerUpEvent(Offset position) {}
}