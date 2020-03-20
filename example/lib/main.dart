import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:measurements/measurements.dart';
import 'package:measurements_example/colors.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _filePath;
  int viewId;

  static String originalTitle = 'Measurement app';
  String title = originalTitle;
  bool measure = false;
  bool showOriginalSize = false;

  StreamController<double> distanceStream;

  @override
  void initState() {
    super.initState();
    loadPdf();

    distanceStream = StreamController<double>();
    distanceStream.stream.listen((double distance) {
      setState(() {
        this.title = "Distance: ${distance.toStringAsFixed(2)} mm";
      });
    });
  }

  Future<void> loadPdf() async {
    final directory = await getApplicationDocumentsDirectory();
    final File file = File(directory.path + "/TechDraw_Workbench_Example.pdf");

    if (!file.existsSync()) {
      final stream = await http.get('http://192.168.2.133:8000/TechDraw_Workbench_Example.pdf');
      file.writeAsBytes(stream.bodyBytes);
    }

    if (!mounted) return;

    setState(() {
      _filePath = file.path;
    });
  }

  Color getButtonColor(bool selected) {
    if (selected) {
      return selectedColor;
    } else {
      return unselectedColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (_filePath == null) {
      child = Text("Pdf not loaded yet");
    } else {
      child = MeasurementView(
          child: Image.asset("assets/images/TechDraw_Workbench_Example.png"),
          scale: 1 / 2.0,
          outputSink: distanceStream.sink,
          measure: measure,
          showOriginalSize: showOriginalSize);
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              IconButton(onPressed: () {
                setState(() {
                  measure = !measure;
                  title = originalTitle;
                });
              },
                  icon: Icon(Icons.straighten, color: getButtonColor(measure))),
              IconButton(onPressed: () {
                setState(() {
                  showOriginalSize = !showOriginalSize;
                });
              },
                  icon: Icon(Icons.adjust, color: getButtonColor(showOriginalSize))),
              Text(title),
            ],
          ),
        ),
        body:
        child
        ,

      )
      ,
    );
  }

  @override
  void dispose() {
    distanceStream.close();
    super.dispose();
  }
}
