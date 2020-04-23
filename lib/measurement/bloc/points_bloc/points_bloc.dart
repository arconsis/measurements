import 'dart:async';
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:measurements/measurement/bloc/points_bloc/points_event.dart';
import 'package:measurements/measurement/bloc/points_bloc/points_state.dart';
import 'package:measurements/measurement/repository/measurement_repository.dart';
import 'package:measurements/metadata/repository/metadata_repository.dart';

class PointsBloc extends Bloc<PointsEvent, PointsState> {
  MeasurementRepository _measureRepository;
  MetadataRepository _metadataRepository;

  StreamSubscription _onlyPointsSubscription;
  StreamSubscription _pointsAndDistancesSubscription;

  Offset _viewCenter;

  PointsBloc() {
    _measureRepository = GetIt.I<MeasurementRepository>();

    _onlyPointsSubscription = _measureRepository.points.listen((points) {
      add(PointsOnlyEvent(points));
    });

    _pointsAndDistancesSubscription = _measureRepository.drawingHolder.listen((holder) {
      add(PointsAndDistancesEvent(holder.points, holder.distances));
    });

    _metadataRepository = GetIt.I<MetadataRepository>();

    _metadataRepository.showDistances.listen((showDistances) {
      if (showDistances) {
        _pointsAndDistancesSubscription?.resume();
        _onlyPointsSubscription?.pause();
      } else {
        _onlyPointsSubscription?.resume();
        _pointsAndDistancesSubscription?.pause();
      }
    });

    _metadataRepository.viewCenter.listen((center) => _viewCenter = center);
  }

  @override
  PointsState get initialState => PointsEmptyState();

  @override
  Stream<PointsState> mapEventToState(PointsEvent event) async* {
    if (event is PointsOnlyEvent) {
      yield PointsOnlyState(event.points);
    } else if (event is PointsAndDistancesEvent) {
      yield PointsAndDistanceState(event.points, event.distances, _viewCenter);
    }
  }
}
