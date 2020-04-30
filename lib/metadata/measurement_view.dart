import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:measurements/measurement/bloc/measure_bloc/measure_bloc.dart';
import 'package:measurements/measurement/bloc/points_bloc/points_bloc.dart';
import 'package:measurements/measurement/overlay/measure_area.dart';
import 'package:measurements/measurement/repository/measurement_repository.dart';

import '../util/logger.dart';
import 'bloc/metadata_bloc.dart';
import 'bloc/metadata_event.dart';
import 'bloc/metadata_state.dart';
import 'repository/metadata_repository.dart';

/*
 * TODO list:
 * - bug
 *  x slow movement of points - states are equal -> no update
 *  - metadata not loaded on start
 *  - when distances error during movement
 *  - onEvent and map is called multiple times for each point update
 *  - distance switch provided twice
 *  - switching between "showDistances" and "dontShowDistances" has no immediate effect
 *
 * - features
 *  - orientation change not supported
 *  - slow movement should move points with half distance
 *  - delete points
 *
 * - improve
 *  - state for painting with distances should contain holders
 *  - add/update tests
 *
 * - comments from Christof
 */


class Measurement extends StatelessWidget {
  final Widget child;
  final Size documentSize;
  final double scale;
  final double zoom;
  final bool measure;
  final bool showDistanceOnLine;
  final Color measurePaintColor;
  final Function(List<double>) distanceCallback;

  Measurement({
    Key key,
    @required this.child,
    this.documentSize = const Size(210, 297),
    this.scale = 1.0,
    this.zoom = 1.0,
    this.measure = false,
    this.showDistanceOnLine = false,
    this.distanceCallback,
    this.measurePaintColor
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
        measurePaintColor,
      ),
    );
  }
}

class MeasurementView extends StatefulWidget {
  final Widget child;
  final Size documentSize;
  final double scale;
  final double zoom;
  final bool measure;
  final bool showDistanceOnLine;
  final Color measurePaintColor;
  final Function(List<double>) distanceCallback;

  MeasurementView(this.child,
      this.documentSize,
      this.scale,
      this.zoom,
      this.measure,
      this.showDistanceOnLine,
      this.distanceCallback,
      this.measurePaintColor);

  @override
  _MeasurementViewState createState() => _MeasurementViewState();
}

class _MeasurementViewState extends State<MeasurementView> {
  Logger logger = Logger(LogDistricts.MEASUREMENT_VIEW);
  GlobalKey childKey = GlobalKey();

  @override
  void didChangeDependencies() {
    logger.log("didChangeDependencies");

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(MeasurementView oldWidget) {
    logger.log("didUpdateWidget");

    BlocProvider.of<MetadataBloc>(context).add(
        MetadataStartedEvent(
            widget.documentSize,
            widget.distanceCallback,
            widget.scale,
            widget.zoom,
            widget.measure,
            widget.showDistanceOnLine,
            widget.measurePaintColor)
    );
    _setBackgroundImageToBloc();

    super.didUpdateWidget(oldWidget);
  }

  void _setBackgroundImageToBloc() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (childKey.currentContext != null) {
        // TODO is a heavy operation and is called after every movement of any point
        RenderRepaintBoundary boundary = childKey.currentContext.findRenderObject();

        if (boundary.size.width > 0.0 && boundary.size.height > 0.0) {
          BlocProvider.of<MetadataBloc>(context).add(MetadataBackgroundEvent(await boundary.toImage(pixelRatio: 4.0), boundary.size));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MetadataBloc, MetadataState>(
        builder: (context, state) {
          return _overlay(state);
        }
    );
  }

  Widget _overlay(MetadataState state) {
    if (state.measure) {
      return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => MeasureBloc(),),
            BlocProvider(create: (context) => PointsBloc(),),
          ],
          child: MeasureArea(
            paintColor: widget.measurePaintColor, // TODO can UI-only parameters be passed like this?
            child: RepaintBoundary(
              key: childKey,
              child: OrientationBuilder(builder: (BuildContext context, Orientation orientation) {
                BlocProvider.of<MetadataBloc>(context).add(MetadataOrientationEvent(orientation));
                return widget.child;
              }),
            ),
          ));
    } else {
      return widget.child;
    }
  }
}
