import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:measurements/measurement/bloc/measure_bloc/measure_bloc.dart';
import 'package:measurements/measurement/bloc/points_bloc/points_bloc.dart';
import 'package:measurements/measurement/overlay/measure_area.dart';
import 'package:measurements/measurement/repository/measurement_repository.dart';
import 'package:measurements/style/distance_style.dart';
import 'package:measurements/style/magnification_style.dart';
import 'package:measurements/style/point_style.dart';
import 'package:measurements/util/logger.dart';

import 'bloc/metadata_bloc.dart';
import 'bloc/metadata_event.dart';
import 'bloc/metadata_state.dart';
import 'repository/metadata_repository.dart';

/*
 * TODO list:
 * x bugs
 *  x slow movement of points - states are equal -> no update -> copy points and distances in measurement repository instead of using same object
 *  x metadata not loaded on start -> stateless measurementView and update arguments in build method
 *  x when distances are shown error during movement -> detect null values in distance list and don't paint distances there
 *  + onEvent and map is called multiple times for each point update -> only called on start and end if showing distances because movementStarted/Finished method
 *  + distance switch provided twice -> correct because measurementView is build twice
 *  x switching between "showDistances" and "dontShowDistances" has no immediate effect -> stream subscriptions have to be canceled and recreated. Pause can be stacked -> one resume is not enough
 *  + after changing "showDistances" flag no measurements possible -> fixed with above bug
 *  x switching measure off and back on causes exception when points are set
 *
 * - features
 *  x orientation change not supported -> calculate viewWidthRatio and multiply points by that ratio
 *  x line type through style
 *  x class to style points (color, size, etc.) -> separate style classes for points, distances and magnification
 *  x return tolerance (size of one pixel in converted mm) (and add as info to displayed distance)
 *  - different units of measurement (request unit of document dimensions)
 *  - incorporate zoomable widget as child
 *  - delete points
 *  - class to style delete (position, widget, etc.)
 *
 * - nice to have, maybe sometime
 *  - slow movement should move points with half distance
 *  - option to return surface area (need to close contour)
 *  - snap to line
 *
 *  - example app to control ALL features
 *
 * - improve
 *  x add/update tests
 *  x state for painting with distances should contain holders
 *  x use arconsis blue as default
 *  x mag-glass below finger when on top and move to sides
 *  - comment for api class
 *  - do correct logging
 *  - initial frames on movement start are slow
 *
 * x comments from Christof
 * - mock repository behaviour or hard code the returned values?
 * - remove GetIt? -> makes repository easily accessible for widget test an validation (Works even when app defined class with same name)
 */


class Measurement extends StatelessWidget {
  final Widget child;
  final Size documentSize;
  final double scale;
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
    this.documentSize = const Size(210, 297),
    this.scale = 1.0,
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
          documentSize,
          scale,
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
  final Size documentSize;
  final double scale;
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
      this.documentSize,
      this.scale,
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
            documentSize,
            distanceCallback,
            distanceToleranceCallback,
            scale,
            zoom,
            measure,
            showDistanceOnLine,
            magnificationStyle)
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