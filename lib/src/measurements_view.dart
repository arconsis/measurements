/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'input_bloc/input_bloc.dart';
import 'input_bloc/input_event.dart';
import 'measurement/bloc/magnification_bloc/magnification_bloc.dart';
import 'measurement/bloc/points_bloc/points_bloc.dart';
import 'measurement/overlay/measure_area.dart';
import 'measurement/repository/measurement_repository.dart';
import 'measurement_controller.dart';
import 'measurement_information.dart';
import 'metadata/bloc/metadata_bloc.dart';
import 'metadata/bloc/metadata_event.dart';
import 'metadata/repository/metadata_repository.dart';
import 'scale_bloc/scale_bloc.dart';
import 'scale_bloc/scale_event.dart';
import 'scale_bloc/scale_state.dart';
import 'style/distance_style.dart';
import 'style/magnification_style.dart';
import 'style/point_style.dart';
import 'util/colors.dart';
import 'util/logger.dart';

class _DeleteChild extends StatelessWidget {
  const _DeleteChild();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.highlight_off,
      size: 75,
      color: Color.fromARGB(100, 50, 50, 50),
    );
  }
}

/// This widget displays its child and allows you to measure distances on its content.
///
/// [child] should be without any padding or margins, because the dimensions passed in [measurementInformation] will be assumed over the full width and height of the child.
///
/// [deleteChild] can be any widget but should not cover the whole widget as points are only removed when they are dragged from outside of the bounds of the [deleteChild] into its bounds.
/// To position the [deleteChild] use [deleteChildAlignment].
///
/// When disabling [measure] the user can pan and zoom the document for more precise placement of points or focusing on one specific region.
///
/// When the distances are only needed programmatically, the displaying of the distances can be disabled with [showDistanceOnLine].
///
/// To change which unit of measurement you want the distances to be use [measurementInformation].
/// The dimensions and scale of the document also have to be set in the [measurementInformation].
///
/// When you need the distances and tolerance in code or want to reset the zoom or zoom the document to life-size set a [MeasurementController] to [controller].
///
/// Changing how much the magnification glass zooms in set [magnificationZoomFactor] accordingly, but don't go too wild as that might break it.
/// To style the appearance of the UI elements you can use [PointStyle], [MagnificationStyle] and [DistanceStyle] in [pointStyle], [magnificationStyle] and [distanceStyle] respectively.
class Measurements extends StatelessWidget {
  final Widget child;
  final Widget deleteChild;
  final Alignment deleteChildAlignment;
  final bool measure;
  final bool showDistanceOnLine;
  final MeasurementInformation measurementInformation;
  final double magnificationZoomFactor;
  final MeasurementController controller;
  final PointStyle pointStyle;
  final MagnificationStyle magnificationStyle;
  final DistanceStyle distanceStyle;

  Measurements({
    Key key,
    @required this.child,
    this.deleteChild = const _DeleteChild(),
    this.deleteChildAlignment = Alignment.bottomCenter,
    this.measure = true,
    this.showDistanceOnLine = true,
    this.measurementInformation = const MeasurementInformation.dinA4(),
    this.magnificationZoomFactor = 2.0,
    this.controller,
    this.pointStyle = const PointStyle(),
    this.magnificationStyle = const MagnificationStyle(),
    this.distanceStyle = const DistanceStyle(),
  }) {
    if (!GetIt.I.isRegistered<MetadataRepository>()) {
      GetIt.I.registerSingleton(MetadataRepository());
    }
    if (!GetIt.I.isRegistered<MeasurementRepository>()) {
      GetIt.I.registerSingleton(
          MeasurementRepository(GetIt.I<MetadataRepository>()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => MetadataBloc()),
        BlocProvider(create: (context) => InputBloc()),
        BlocProvider(create: (context) => ScaleBloc()),
      ],
      child: _Measurements(
        child,
        deleteChild,
        deleteChildAlignment,
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

class _Measurements extends StatelessWidget {
  final Logger _logger = Logger(LogDistricts.MEASUREMENT_VIEW);
  final GlobalKey _childKey = GlobalKey();
  final GlobalKey _parentKey = GlobalKey();
  final GlobalKey _deleteKey = GlobalKey();

  final Widget child;
  final Widget deleteChild;
  final Alignment deleteChildAlignment;
  final bool measure;
  final bool showDistanceOnLine;
  final MeasurementInformation measurementInformation;
  final double magnificationZoomFactor;
  final MeasurementController controller;
  final PointStyle pointStyle;
  final MagnificationStyle magnificationStyle;
  final DistanceStyle distanceStyle;

  _Measurements(
    this.child,
    this.deleteChild,
    this.deleteChildAlignment,
    this.measure,
    this.showDistanceOnLine,
    this.measurementInformation,
    this.magnificationZoomFactor,
    this.controller,
    this.pointStyle,
    this.magnificationStyle,
    this.distanceStyle,
  );

  void _setBackgroundImageToBloc(BuildContext context, double zoom) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_childKey.currentContext != null) {
        RenderRepaintBoundary boundary =
            _childKey.currentContext.findRenderObject();

        if (boundary.size.width > 0.0 && boundary.size.height > 0.0) {
          final pixelRatio =
              min(10.0, max(1.0, magnificationZoomFactor * zoom));
          final image = await boundary.toImage(pixelRatio: pixelRatio);

          if (image.width > 0) {
            BlocProvider.of<MetadataBloc>(context)
                .add(MetadataBackgroundEvent(image, boundary.size));
          }
        } else {
          _logger.log('image dimensions are 0');
        }
      }
    });
  }

  void _setScreenInfoToBloc(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_deleteKey.currentContext != null &&
          _parentKey.currentContext != null) {
        var parentObject = _parentKey.currentContext.findRenderObject();
        var deleteObject = _deleteKey.currentContext.findRenderObject();

        final translation =
            deleteObject.getTransformTo(parentObject).getTranslation();
        var deleteSize = _deleteKey.currentContext.size;

        _logger.log('Translation is: $translation size is $deleteSize');

        BlocProvider.of<MetadataBloc>(context)
            ?.add(MetadataScreenSizeEvent(_parentKey.currentContext.size));
        BlocProvider.of<MetadataBloc>(context)?.add(MetadataDeleteRegionEvent(
            Offset(translation.x, translation.y), deleteSize));
      }
    });
  }

  void _setStartupArgumentsToBloc(BuildContext context) {
    BlocProvider.of<MetadataBloc>(context)?.add(MetadataStartedEvent(
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
      key: _parentKey,
      color: drawColor,
      child: BlocBuilder<ScaleBloc, ScaleState>(
        builder: (context, scaleState) => _overlay(context, scaleState),
      ),
    );
  }

  Widget _overlay(BuildContext context, ScaleState scaleState) {
    return OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
      _setBackgroundImageToBloc(context, scaleState.scale);
      _setScreenInfoToBloc(context);

      return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => PointsBloc()),
          BlocProvider(
              create: (context) =>
                  MagnificationBloc(BlocProvider.of<InputBloc>(context))),
        ],
        child: Listener(
          onPointerDown: (PointerDownEvent event) =>
              BlocProvider.of<InputBloc>(context)
                  .add(InputDownEvent(event.localPosition)),
          onPointerMove: (PointerMoveEvent event) =>
              BlocProvider.of<InputBloc>(context)
                  .add(InputMoveEvent(event.localPosition)),
          onPointerUp: (PointerUpEvent event) =>
              BlocProvider.of<InputBloc>(context)
                  .add(InputUpEvent(event.localPosition)),
          child: Stack(
            children: <Widget>[
              Transform(
                transform: scaleState.transform,
                alignment: Alignment.center,
                child: RepaintBoundary(
                  key: _childKey,
                  child: child,
                ),
              ),
              MeasureArea(
                pointStyle: pointStyle,
                magnificationStyle: magnificationStyle,
                distanceStyle: distanceStyle,
              ),
              Align(
                alignment: deleteChildAlignment,
                child: Container(
                  key: _deleteKey,
                  child: deleteChild,
                ),
              ),
              GestureDetector(
                onScaleStart: (ScaleStartDetails details) =>
                    BlocProvider.of<ScaleBloc>(context)
                        .add(ScaleStartEvent(details.localFocalPoint)),
                onScaleUpdate: (ScaleUpdateDetails details) =>
                    BlocProvider.of<ScaleBloc>(context).add(ScaleUpdateEvent(
                        details.localFocalPoint, details.scale)),
                onDoubleTap: () => BlocProvider.of<ScaleBloc>(context)
                    .add(ScaleDoubleTapEvent()),
              )
            ],
          ),
        ),
      );
    });
  }
}
