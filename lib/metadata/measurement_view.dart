import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:measurements/measurement/bloc/measurement_bloc.dart';
import 'package:measurements/measurement/overlay/measure_area.dart';
import 'package:measurements/measurement/repository/measurement_repository.dart';

import '../util/logger.dart';
import 'bloc/metadata_bloc.dart';
import 'bloc/metadata_event.dart';
import 'bloc/metadata_state.dart';
import 'repository/metadata_repository.dart';

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
    GetIt.I.registerSingleton(MetadataRepository());
    GetIt.I.registerSingleton(MeasurementRepository());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MetadataBloc(GetIt.I.get<MetadataRepository>()),
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
  Logger logger = Logger(LogDistricts.MEASUREMENT);
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

  void _setBackgroundImageToBloc() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.measure) {
        RenderRepaintBoundary boundary = childKey.currentContext.findRenderObject();

        BlocProvider.of(context).add(MetadataBackgroundEvent(await boundary.toImage(pixelRatio: 4.0), boundary.size.width));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (BuildContext context, Orientation orientation) {
      BlocProvider.of<MetadataBloc>(context).add(MetadataOrientationEvent(orientation));

      return BlocBuilder<MetadataBloc, MetadataState>(
          builder: (context, state) {
            return _overlay(state);
          }
      );
    });
  }

  Widget _overlay(MetadataState state) {
    if (state.measure) {
      return BlocProvider(
        create: (context) => MeasurementBloc(),
        child: MeasureArea(
          paintColor: widget.measurePaintColor, // TODO can UI-only parameters be passed like this?
          child: RepaintBoundary(
            key: childKey,
            child: widget.child,
          ),
        ),
      );
    } else {
      return widget.child;
    }
  }
}
