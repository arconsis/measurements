///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:measurements/measurements.dart';
import 'package:measurements_example/colors.dart';

class MetadataRepository {}

void main() {
  GetIt.I.registerSingleton(MetadataRepository());

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static String originalTitle = 'Measurement app';
  String title = originalTitle;
  bool measure = true;
  bool showDistanceOnLine = true;
  bool showTolerance = false;

  List<LengthUnit> unitsOfMeasurement = [Meter.asUnit(), Millimeter.asUnit(), Inch.asUnit(), Foot.asUnit()];
  int unitIndex = 0;

  Function(List<double>) distanceCallback;

  @override
  void initState() {
    super.initState();

    distanceCallback = (List<double> distance) {
      setState(() {
        this.title = "Measurement#: ${distance.length}";
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
          backgroundColor: Color(0xff1280b3),
          title: Row(
            children: <Widget>[
              IconButton(onPressed: () =>
                  setState(() {
                    measure = !measure;
                    title = originalTitle;
                  }),
                  icon: Icon(Icons.straighten, color: getButtonColor(measure))
              ),
              IconButton(onPressed: () =>
                  setState(() => showDistanceOnLine = !showDistanceOnLine),
                  icon: Icon(Icons.vertical_align_bottom, color: getButtonColor(showDistanceOnLine))
              ),
              SizedBox.fromSize(
                child: MaterialButton(
                  shape: CircleBorder(),
                  onPressed: () =>
                      setState(() => showTolerance = !showTolerance),
                  child: Text("±"),
                  textColor: getButtonColor(showTolerance),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                size: Size(52, 52),
              ),
              SizedBox.fromSize(
                child: MaterialButton(
                  shape: CircleBorder(),
                  onPressed: () =>
                      setState(() => unitIndex = (unitIndex + 1) % unitsOfMeasurement.length),
                  child: Text(unitsOfMeasurement[unitIndex].getAbbreviation()),
                  textColor: unselectedColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                size: Size(64, 64),
              ),
              Text(title),
            ],
          ),
        ),
        body: Center(
          child: Measurement(
            child: Image.asset("assets/images/example_portrait.png",),
            measurementInformation: MeasurementInformation(
              scale: 1 / 2.0,
              documentWidthInLengthUnits: Millimeter(210),
              targetLengthUnit: unitsOfMeasurement[unitIndex],
            ),
            distanceCallback: distanceCallback,
            showDistanceOnLine: showDistanceOnLine,
            distanceStyle: DistanceStyle(numDecimalPlaces: 2, showTolerance: showTolerance),
            measure: measure,
            pointStyle: PointStyle(lineType: DashedLine()),
          ),
        ),
      ),
    );
  }
}
