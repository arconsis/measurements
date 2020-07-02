import 'dart:math';

///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:measurements/input_state/input_bloc.dart';
import 'package:measurements/measurement/bloc/magnification_bloc/magnification_bloc.dart';
import 'package:photo_view/photo_view.dart';

import 'input_state/input_event.dart';
import 'measurement/bloc/points_bloc/points_bloc.dart';
import 'measurement/overlay/measure_area.dart';
import 'measurement/repository/measurement_repository.dart';
import 'measurement_controller.dart';
import 'measurement_information.dart';
import 'metadata/bloc/metadata_bloc.dart';
import 'metadata/bloc/metadata_event.dart';
import 'metadata/bloc/metadata_state.dart';
import 'metadata/repository/metadata_repository.dart';
import 'style/distance_style.dart';
import 'style/magnification_style.dart';
import 'style/point_style.dart';
import 'util/colors.dart';
import 'util/logger.dart';

class Measurement extends StatelessWidget {
  final Widget child;
  final Widget deleteChild;
  final bool measure;
  final bool showDistanceOnLine;
  final MeasurementInformation measurementInformation;
  final double magnificationZoomFactor;
  final MeasurementController controller;
  final PointStyle pointStyle;
  final MagnificationStyle magnificationStyle;
  final DistanceStyle distanceStyle;

  Measurement({
    Key key,
    @required this.child,
    this.deleteChild,
    this.measure = false,
    this.showDistanceOnLine = false,
    this.measurementInformation = const MeasurementInformation.A4(),
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
      GetIt.I.registerSingleton(MeasurementRepository(GetIt.I<MetadataRepository>()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => MetadataBloc()),
        BlocProvider(create: (context) => InputBloc()),
      ],
      child: MeasurementView(
        child,
        deleteChild,
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
  final GlobalKey _parentKey = GlobalKey();
  final GlobalKey _deleteKey = GlobalKey();

  final Widget child;
  final Widget deleteChild;
  final bool measure;
  final bool showDistanceOnLine;
  final MeasurementInformation measurementInformation;
  final double magnificationZoomFactor;
  final MeasurementController controller;
  final PointStyle pointStyle;
  final MagnificationStyle magnificationStyle;
  final DistanceStyle distanceStyle;

  MeasurementView(
    this.child,
    this.deleteChild,
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
        RenderRepaintBoundary boundary = _childKey.currentContext.findRenderObject();

        if (boundary.size.width > 0.0 && boundary.size.height > 0.0) {
          final pixelRatio = min(10.0, max(1.0, magnificationZoomFactor * zoom));
          final image = await boundary.toImage(pixelRatio: pixelRatio);

          if (image.width > 0) {
            BlocProvider.of<MetadataBloc>(context).add(MetadataBackgroundEvent(image, boundary.size));
          }
        } else {
          _logger.log("image dimensions are 0");
        }
      }
    });
  }

  void _setDeleteChildInfoToBloc(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_deleteKey.currentContext != null && _parentKey.currentContext != null) {
        RenderObject parentObject = _parentKey.currentContext.findRenderObject();
        RenderObject deleteObject = _deleteKey.currentContext.findRenderObject();

        final translation = deleteObject.getTransformTo(parentObject).getTranslation();
        Size deleteSize = _deleteKey.currentContext.size;

        _logger.log("Translation is: $translation size is $deleteSize");

        BlocProvider.of<MetadataBloc>(context).add(MetadataDeleteRegionEvent(Offset(translation.x, translation.y), deleteSize));
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
      key: _parentKey,
      color: drawColor,
      child: BlocBuilder<MetadataBloc, MetadataState>(
        builder: (context, state) => _overlay(context, state),
      ),
    );
  }

  Widget _overlay(BuildContext context, MetadataState state) {
    return OrientationBuilder(builder: (BuildContext context, Orientation orientation) {
      BlocProvider.of<MetadataBloc>(context).add(MetadataOrientationEvent(orientation));
      _setBackgroundImageToBloc(context, state.zoom);
      _setDeleteChildInfoToBloc(context);

      return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => PointsBloc()),
          BlocProvider(create: (context) => MagnificationBloc(BlocProvider.of<InputBloc>(context))),
        ],
        child: Listener(
          onPointerDown: (PointerDownEvent event) => BlocProvider.of<InputBloc>(context).add(InputDownEvent(event.localPosition)),
          onPointerMove: (PointerMoveEvent event) {
            _logger.log("move event ${event.toStringFull()}");
            BlocProvider.of<InputBloc>(context).add(InputMoveEvent(event.localPosition));
          },
          onPointerUp: (PointerUpEvent event) => BlocProvider.of<InputBloc>(context).add(InputUpEvent(event.localPosition)),
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
                  child: Container(
                    key: _deleteKey,
                    color: Color.fromARGB(50, 100, 100, 255),
                    child: deleteChild,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
