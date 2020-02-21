import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:measurements/measurements.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _filePath;
  int viewId;

  String title = 'Measurement app';

  StreamController<double> distanceStream;

  @override
  void initState() {
    super.initState();
    loadPdf();

    distanceStream = StreamController<double>();
    distanceStream.stream.listen((double distance) {
      print("Returned distance is $distance");
      title = "Distance: $distance mm";
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> loadPdf() async {
    final directory = await getApplicationDocumentsDirectory();
    final File file = File(directory.path + "/measurementTest.pdf");

    if (!file.existsSync()) {
      final stream = await http.get('https://sample-videos.com/pdf/Sample-pdf-5mb.pdf');
      file.writeAsBytes(stream.bodyBytes);
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _filePath = file.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (_filePath == null) {
      child = Text("Pdf not loaded yet");
    } else {
      child = MeasurementView(filePath: _filePath,
          onViewCreated: (int id) => print("PDF View Id: $id"),
          scale: 1.0,
          outputStream: distanceStream.sink,
          measure: true);
    }

    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: Container(
            height: 700,
            child: child,
          )
      ),
    );
  }

  @override
  void dispose() {
    distanceStream.close();
    super.dispose();
  }
}
