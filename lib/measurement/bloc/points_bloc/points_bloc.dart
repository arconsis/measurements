import 'dart:async';
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:measurements/measurement/bloc/points_bloc/points_event.dart';
import 'package:measurements/measurement/bloc/points_bloc/points_state.dart';
import 'package:measurements/measurement/drawing_holder.dart';
import 'package:measurements/measurement/overlay/holder.dart';
import 'package:measurements/measurement/repository/measurement_repository.dart';
import 'package:measurements/metadata/repository/metadata_repository.dart';
import 'package:measurements/util/logger.dart';
import 'package:measurements/util/utils.dart';

class PointsBloc extends Bloc<PointsEvent, PointsState> {
  final _logger = Logger(LogDistricts.POINTS_BLOC);

  MeasurementRepository _measureRepository;
  MetadataRepository _metadataRepository;

  StreamSubscription _onlyPointsSubscription;
  StreamSubscription _pointsAndDistancesSubscription;

  Function(List<Offset>) _pointsListener;
  Function(DrawingHolder) _pointsAndDistanceListener;

  Offset _viewCenter;
  double _tolerance;

  PointsBloc() {
    _pointsListener = (points) => add(PointsOnlyEvent(points));
    _pointsAndDistanceListener = (holder) => add(PointsAndDistancesEvent(holder.points, holder.distances));

    _measureRepository = GetIt.I<MeasurementRepository>();
    _metadataRepository = GetIt.I<MetadataRepository>();

    _metadataRepository.showDistances.listen((showDistances) {
      _onlyPointsSubscription?.cancel();
      _pointsAndDistancesSubscription?.cancel();

      if (showDistances) {
        _pointsAndDistancesSubscription = _measureRepository.drawingHolder.listen(_pointsAndDistanceListener);
      } else {
        _onlyPointsSubscription = _measureRepository.points.listen(_pointsListener);
      }
    });

    _metadataRepository.viewCenter.listen((center) => _viewCenter = center);
    _metadataRepository.tolerance.listen((tolerance) => _tolerance = tolerance);

    _logger.log("Created Bloc");
  }

  @override
  PointsState get initialState => PointsEmptyState();

  @override
  void onEvent(PointsEvent event) {
    _logger.log("received event: $event");
    super.onEvent(event);
  }

  @override
  Stream<PointsState> mapEventToState(PointsEvent event) async* {
    if (event.points.length == 0) {
      yield PointsEmptyState();
    } else if (event.points.length == 1) {
      yield PointsSingleState(event.points[0]);
    } else {
      if (event is PointsOnlyEvent) {
        yield PointsOnlyState(event.points);
      } else if (event is PointsAndDistancesEvent) {
        List<Holder> holders = List();
        event.points.doInBetween((start, end) => holders.add(Holder(start, end)));
        event.distances.zip(holders, (double distance, Holder holder) => holder.distance = distance);

        if (event.distances.contains(null)) {
          List<int> nullIndices = List();
          nullIndices.add(event.distances.indexOf(null));
          nullIndices.add(event.distances.lastIndexOf(null));

          yield PointsAndDistanceActiveState(holders, _viewCenter, _tolerance, nullIndices);
        } else if (event.points.length - 1 > event.distances.length) {
          yield PointsAndDistanceActiveState(holders, _viewCenter, _tolerance, [event.distances.length]);
        } else {
          yield PointsAndDistanceState(holders, _viewCenter, _tolerance);
        }
      }
    }
  }
}
