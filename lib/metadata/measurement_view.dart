///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:measurements/measurement/bloc/measure_bloc/measure_bloc.dart';
import 'package:measurements/measurement/bloc/points_bloc/points_bloc.dart';
import 'package:measurements/measurement/overlay/measure_area.dart';
import 'package:measurements/measurement/repository/measurement_repository.dart';
import 'package:measurements/metadata/measurement_information.dart';
import 'package:measurements/style/distance_style.dart';
import 'package:measurements/style/magnification_style.dart';
import 'package:measurements/style/point_style.dart';
import 'package:measurements/util/logger.dart';

import 'bloc/metadata_bloc.dart';
import 'bloc/metadata_event.dart';
import 'bloc/metadata_state.dart';
import 'repository/metadata_repository.dart';


class Measurement extends StatelessWidget {
  final Widget child;
  final MeasurementInformation measurementInformation;
  final double zoom;
  final double magnificationZoomFactor;
  final bool measure;
  final bool showDistanceOnLine;
  final Function(List<double>) distanceCallback;
  final Function(double) distanceToleranceCallback;
  final PointStyle pointStyle;
  final MagnificationStyle magnificationStyle;
  final DistanceStyle distanceStyle;

  Measurement({
    Key key,
    @required this.child,
    this.measurementInformation = const MeasurementInformation(),
    this.zoom = 1.0,
    this.measure = false,
    this.showDistanceOnLine = false,
    this.distanceCallback,
    this.distanceToleranceCallback,
    this.magnificationZoomFactor = 2.0,
    this.pointStyle = const PointStyle(),
    this.magnificationStyle = const MagnificationStyle(),
    this.distanceStyle = const DistanceStyle()
  }) {
    if (!GetIt.I.isRegistered<MetadataRepository>()) {
      GetIt.I.registerSingleton(MetadataRepository());
    }
    if (!GetIt.I.isRegistered<MeasurementRepository>()) {
      GetIt.I.registerSingleton(MeasurementRepository(GetIt.I<MetadataRepository>()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MetadataBloc(),
      child: MeasurementView(
          child,
          measurementInformation,
          zoom,
          measure,
          showDistanceOnLine,
          distanceCallback,
          distanceToleranceCallback,
          magnificationZoomFactor,
          pointStyle,
          magnificationStyle,
          distanceStyle
      ),
    );
  }
}

class MeasurementView extends StatelessWidget {
  final Logger _logger = Logger(LogDistricts.MEASUREMENT_VIEW);
  final GlobalKey _childKey = GlobalKey();

  final Widget child;
  final MeasurementInformation measurementInformation;
  final double zoom;
  final double magnificationZoomFactor;
  final bool measure;
  final bool showDistanceOnLine;
  final Function(List<double>) distanceCallback;
  final Function(double) distanceToleranceCallback;
  final PointStyle pointStyle;
  final MagnificationStyle magnificationStyle;
  final DistanceStyle distanceStyle;

  MeasurementView(this.child,
      this.measurementInformation,
      this.zoom,
      this.measure,
      this.showDistanceOnLine,
      this.distanceCallback,
      this.distanceToleranceCallback,
      this.magnificationZoomFactor,
      this.pointStyle,
      this.magnificationStyle,
      this.distanceStyle);

  void _setBackgroundImageToBloc(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_childKey.currentContext != null) {
        RenderRepaintBoundary boundary = _childKey.currentContext.findRenderObject();

        if (boundary.size.width > 0.0 && boundary.size.height > 0.0) {
          BlocProvider.of<MetadataBloc>(context).add(MetadataBackgroundEvent(await boundary.toImage(pixelRatio: magnificationZoomFactor), boundary.size));
        } else {
          _logger.log("image dimensions are 0");
          _setBackgroundImageToBloc(context);
        }
      }
    });
  }

  void _setStartupArgumentsToBloc(BuildContext context) {
    BlocProvider.of<MetadataBloc>(context).add(
        MetadataStartedEvent(
          measurementInformation: measurementInformation,
          measure: measure,
          showDistances: showDistanceOnLine,
          zoom: zoom,
          magnificationStyle: magnificationStyle,
          callback: distanceCallback,
          toleranceCallback: distanceToleranceCallback,
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    _logger.log("building");
    _setStartupArgumentsToBloc(context);

    return OrientationBuilder(builder: (BuildContext context, Orientation orientation) {
      _setBackgroundImageToBloc(context);
      return BlocBuilder<MetadataBloc, MetadataState>(
          builder: (context, state) {
            return _overlay(state);
          }
      );
    });
  }

  Widget _overlay(MetadataState state) {
    if (state.measure) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => MeasureBloc(),),
          BlocProvider(create: (context) => PointsBloc(),),
        ],
        child: MeasureArea(
          pointStyle: pointStyle,
          magnificationStyle: magnificationStyle,
          distanceStyle: distanceStyle, // TODO can UI-only parameters be passed like this?
          child: RepaintBoundary(
            key: _childKey,
            child: child,
          ),
        ),
      );
    } else {
      return child;
    }
  }
}