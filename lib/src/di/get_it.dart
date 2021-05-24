import 'package:get_it/get_it.dart';

import '../measurement/repository/measurement_repository.dart';
import '../metadata/repository/metadata_repository.dart';

final _getIt = GetIt.instance;

void registerMembers() {
  if (!GetIt.I.isRegistered<MetadataRepository>()) {
    GetIt.I.registerSingleton(MetadataRepository());
  }
  if (!GetIt.I.isRegistered<MeasurementRepository>()) {
    GetIt.I.registerSingleton(MeasurementRepository(GetIt.I<MetadataRepository>()));
  }
}

T get<T extends Object>() => _getIt.get<T>();
