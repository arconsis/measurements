import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:measurements/bloc/bloc_provider.dart';
import 'package:measurements/measurement_bloc.dart';

typedef OnViewCreated(int id);

class PdfView extends StatefulWidget {
  const PdfView({
    Key key,
    this.filePath,
    this.onViewCreated,
  });

  final String filePath;
  final OnViewCreated onViewCreated;

  @override
  State<StatefulWidget> createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  MeasurementBloc _bloc;
  EventChannel _zoomEventChannel;
  MethodChannel _zoomToMethodChannel;

  StreamSubscription zoomToSubscription;

  GlobalKey _pdfViewKey = GlobalKey();

  @override
  void initState() {
    _bloc = BlocProvider.of(context);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return AndroidView(
        key: _pdfViewKey,
        viewType: "measurement_view",
        creationParams: <String, dynamic>{
          "filePath": widget.filePath,
        },
        creationParamsCodec: StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }

    return Text("${Platform.operatingSystem} is not supported yet");
  }

  void _onPlatformViewCreated(int id) {
    print("measure_flutter: New Platform View created with id: $id");
    final RenderBox pdfViewBox = _pdfViewKey.currentContext.findRenderObject();
    if (pdfViewBox.size != null) {
      _bloc.setLogicalPdfViewWidth(pdfViewBox.size.width);
      print("measure_flutter: Android View Render Obejct id: ${_pdfViewKey.currentWidget}");
    }

    _zoomEventChannel = EventChannel("measurement_pdf_zoom_$id");
    _zoomEventChannel.receiveBroadcastStream().listen((dynamic data) {
      _bloc.setZoomLevel(data);
    });

    _zoomToMethodChannel = MethodChannel("measurement_pdf_set_zoom_$id");

    if (zoomToSubscription == null) {
      zoomToSubscription = _bloc.zoomToStream.listen((double event) {
        print("measure_flutter: invoking set zoom method with zoom level: $event");
        _zoomToMethodChannel.invokeMethod("setZoom", 15.0);
      });
    }

    widget?.onViewCreated(id);
  }

  @override
  void dispose() {
    zoomToSubscription.cancel();
    super.dispose();
  }
}