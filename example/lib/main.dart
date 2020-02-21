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
  bool measure = false;

  StreamController<double> distanceStream;

  @override
  void initState() {
    super.initState();
    loadPdf();

    distanceStream = StreamController<double>();
    distanceStream.stream.listen((double distance) {
      title = "Distance: $distance mm";
      setState(() {
        this.title = title;
      });
    });
  }

  Future<void> loadPdf() async {
    final directory = await getApplicationDocumentsDirectory();
    final File file = File(directory.path + "/measurementTest.pdf");

    if (!file.existsSync()) {
      final stream = await http.get('https://sample-videos.com/pdf/Sample-pdf-5mb.pdf');
      file.writeAsBytes(stream.bodyBytes);
    }

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
          scale: 1 / 10.0,
          outputStream: distanceStream.sink,
          measure: measure);
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              Text(title),
              IconButton(onPressed: () {
                setState(() {
                  measure = !measure;
                });
              },
                icon: Icon(Icons.straighten),)
            ],
          ),
        ),
        body: child,

      ),
    );
  }

  @override
  void dispose() {
    distanceStream.close();
    super.dispose();
  }
}
