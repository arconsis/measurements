import 'dart:async';

import 'package:flutter/material.dart';
import 'package:measurements/measurements.dart';
import 'package:measurements_example/colors.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static String originalTitle = 'Measurement app';
  String title = originalTitle;
  bool measure = false;

  StreamController<double> distanceStream;

  @override
  void initState() {
    super.initState();

    distanceStream = StreamController<double>();
    distanceStream.stream.listen((double distance) {
      setState(() {
        this.title = "Distance: ${distance.toStringAsFixed(2)} mm";
      });
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
              Text(title),
            ],
          ),
        ),
        body:
        MeasurementView(
          child: OrientationBuilder(builder: (BuildContext context, Orientation orientation) {
            if (orientation == Orientation.portrait) {
              return Image.asset("assets/images/example_portrait.png", package: "measurements",);
            } else {
              return Image.asset("assets/images/example_portrait.png", package: "measurements",);
              return Image.asset("assets/images/example_landscape.png", package: "measurements",);
            }
          },),
          scale: 1 / 2.0,
          outputSink: distanceStream.sink,
          measure: measure,
        ),
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
