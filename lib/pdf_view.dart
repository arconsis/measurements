import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:measurements/bloc/bloc_provider.dart';
import 'package:measurements/bloc/measurement_bloc.dart';

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
    _bloc.viewId.add(id);

    print("measure_flutter: New Platform View created with id: $id");
    final RenderBox pdfViewBox = _pdfViewKey.currentContext.findRenderObject();
    if (pdfViewBox.size != null) {
      _bloc.viewWidth.add(pdfViewBox.size.width);
      print("measure_flutter: Android View Render Obejct id: ${_pdfViewKey.currentWidget}");
    }

    widget?.onViewCreated(id);
  }
}