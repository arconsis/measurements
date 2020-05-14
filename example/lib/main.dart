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
  bool showDistanceOnLine = false;

  Function(List<double>, double) distanceCallback;

  @override
  void initState() {
    super.initState();

    distanceCallback = (List<double> singleDistances, double overallDistance) {
      setState(() {
        this.title = "Measured Distance: ${overallDistance.round()}";
      });
    };
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
              IconButton(
                  onPressed: () {
                    setState(() {
                      measure = !measure;
                      title = originalTitle;
                    });
                  },
                  icon: Icon(Icons.straighten, color: getButtonColor(measure))),
              IconButton(
                  onPressed: () {
                    setState(() {
                      showDistanceOnLine = !showDistanceOnLine;
                    });
                  },
                  icon: Icon(Icons.vertical_align_bottom,
                      color: getButtonColor(showDistanceOnLine))),
              Text(title),
            ],
          ),
        ),
        body: Center(
          child: MeasurementView(
            child: Image.asset(
              //1432: how can I zoom? -> you can't with this widget
              "assets/images/example_portrait.png",
              package: "measurements",
            ),
            scale: 1 / 2.0,
            distanceCallback: distanceCallback,
            showDistanceOnLine: showDistanceOnLine,
            measure: measure,
          ),
        ),
      ),
    );
  }
}
