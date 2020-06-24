import 'dart:math';

///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:measurements/measurement/bloc/measure_bloc/measure_bloc.dart';
import 'package:measurements/measurement/bloc/measure_bloc/measure_event.dart';
import 'package:measurements/measurement/bloc/points_bloc/points_bloc.dart';
import 'package:measurements/measurement/overlay/measure_area.dart';
import 'package:measurements/measurement/repository/measurement_repository.dart';
import 'package:measurements/measurement_controller.dart';
import 'package:measurements/metadata/measurement_information.dart';
import 'package:measurements/style/distance_style.dart';
import 'package:measurements/style/magnification_style.dart';
import 'package:measurements/style/point_style.dart';
import 'package:measurements/util/colors.dart';
import 'package:measurements/util/logger.dart';
import 'package:photo_view/photo_view.dart';

import 'bloc/metadata_bloc.dart';
import 'bloc/metadata_event.dart';
import 'bloc/metadata_state.dart';
import 'repository/metadata_repository.dart';

class Measurement extends StatelessWidget {
  final Widget child;
  final bool measure;
  final bool showDistanceOnLine;
  final MeasurementInformation measurementInformation;
  final double magnificationZoomFactor;
  final MeasurementController controller;
  final PointStyle pointStyle;
  final MagnificationStyle magnificationStyle;
  final DistanceStyle distanceStyle;

  Measurement(
      {Key key,
      @required this.child,
      this.measure = false,
      this.showDistanceOnLine = false,
      this.measurementInformation = const MeasurementInformation.A4(),
      this.magnificationZoomFactor = 2.0,
      this.controller,
      this.pointStyle = const PointStyle(),
      this.magnificationStyle = const MagnificationStyle(),
      this.distanceStyle = const DistanceStyle()}) {
    if (!GetIt.I.isRegistered<MetadataRepository>()) {
      GetIt.I.registerSingleton(MetadataRepository());
    }
    if (!GetIt.I.isRegistered<MeasurementRepository>()) {
      GetIt.I.registerSingleton(MeasurementRepository(GetIt.I<MetadataRepository>()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => MetadataBloc()),
        BlocProvider(create: (context) => MeasureBloc()),
      ],
      child: MeasurementView(
        child,
        measure,
        showDistanceOnLine,
        measurementInformation,
        magnificationZoomFactor,
        controller,
        pointStyle,
        magnificationStyle,
        distanceStyle,
      ),
    );
  }
}

class MeasurementView extends StatelessWidget {
  final Logger _logger = Logger(LogDistricts.MEASUREMENT_VIEW);
  final GlobalKey _childKey = GlobalKey();

  final Widget child;
  final bool measure;
  final bool showDistanceOnLine;
  final MeasurementInformation measurementInformation;
  final double magnificationZoomFactor;
  final MeasurementController controller;
  final PointStyle pointStyle;
  final MagnificationStyle magnificationStyle;
  final DistanceStyle distanceStyle;

  MeasurementView(
      this.child, this.measure, this.showDistanceOnLine, this.measurementInformation, this.magnificationZoomFactor, this.controller, this.pointStyle, this.magnificationStyle, this.distanceStyle);

  void _setBackgroundImageToBloc(BuildContext context, double zoom) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_childKey.currentContext != null) {
        RenderRepaintBoundary boundary = _childKey.currentContext.findRenderObject();

        if (boundary.size.width > 0.0 && boundary.size.height > 0.0) {
          final pixelRatio = min(10.0, max(1.0, magnificationZoomFactor * zoom));
          final image = await boundary.toImage(pixelRatio: pixelRatio);

          if (image.width > 0) {
            BlocProvider.of<MetadataBloc>(context).add(MetadataBackgroundEvent(image, boundary.size));
          }
        } else {
          _logger.log("image dimensions are 0");
          _setBackgroundImageToBloc(context, zoom);
        }
      }
    });
  }

  void _setStartupArgumentsToBloc(BuildContext context) {
    BlocProvider.of<MetadataBloc>(context).add(MetadataStartedEvent(
      measurementInformation: measurementInformation,
      measure: measure,
      showDistances: showDistanceOnLine,
      magnificationStyle: magnificationStyle,
      controller: controller,
    ));
  }

  @override
  Widget build(BuildContext context) {
    _setStartupArgumentsToBloc(context);

    return Container(
      color: drawColor,
      child: BlocBuilder<MetadataBloc, MetadataState>(
        builder: (context, state) => _overlay(state),
      ),
    );
  }

  Widget _overlay(MetadataState state) {
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        BlocProvider.of<MetadataBloc>(context).add(MetadataOrientationEvent(orientation));
        _setBackgroundImageToBloc(context, state.zoom);

        return BlocProvider(
          create: (context) => PointsBloc(),
          child: Listener(
            onPointerDown: (PointerDownEvent event) => BlocProvider.of<MeasureBloc>(context).add(MeasureDownEvent(event.localPosition)),
            onPointerMove: (PointerMoveEvent event) => BlocProvider.of<MeasureBloc>(context).add(MeasureMoveEvent(event.localPosition)),
            onPointerUp: (PointerUpEvent event) => BlocProvider.of<MeasureBloc>(context).add(MeasureUpEvent(event.localPosition)),
            child: Stack(
              children: <Widget>[
                AbsorbPointer(
                  absorbing: state.measure,
                  child: PhotoView.customChild(
                    controller: state.controller,
                    initialScale: PhotoViewComputedScale.contained,
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.contained * state.maxZoom,
                    child: RepaintBoundary(
                      key: _childKey,
                      child: child,
                    ),
                  ),
                ),
                MeasureArea(
                  pointStyle: pointStyle,
                  magnificationStyle: magnificationStyle,
                  distanceStyle: distanceStyle,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 100,
                    height: 100,
                    color: Color.fromARGB(50, 100, 100, 255),
                    child: Listener(
                      onPointerDown: (PointerDownEvent event) => _logger.log("delete position down: $event"),
                      onPointerMove: (PointerMoveEvent event) => _logger.log("delete position move: $event"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
