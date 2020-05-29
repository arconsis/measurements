import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get_it/get_it.dart';
import 'package:measurements/measurements.dart';
import 'package:measurements_example/colors.dart';

class MetadataRepository {}

void main() {
  GetIt.I.registerSingleton(MetadataRepository());

  runApp(MaterialApp(home: MyApp(),));
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
  _OptionsHolder holder = _OptionsHolder();
  _OptionsHolder tmpHolder = _OptionsHolder();

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff1280b3),
        title: Row(
          children: <Widget>[
            IconButton(
                onPressed: () {
                  setState(() {
                    measure = !measure;
                    title = originalTitle;
                  });
                },
                icon: Icon(Icons.straighten, color: getButtonColor(measure))
            ),
            IconButton(
                onPressed: () {
                  setState(() {
                    showDistanceOnLine = !showDistanceOnLine;
                  });
                },
                icon: Icon(Icons.vertical_align_bottom, color: getButtonColor(showDistanceOnLine))
            ),
            Text(title),
            Spacer(),
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      Container(
                        alignment: Alignment.center,
                        width: 500,
                        height: 700,
                        child: AlertDialog(
                          title: Text("Change Measurement Settings"),
                          content: SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Text("Point Color"),
                                    _getColorPickerButton(context, "Pick Color", "Point Color", tmpHolder.pointColor, (color) => tmpHolder.pointColor = color),
                                    Text("Point Size"),
                                    Slider(
                                      value: tmpHolder.pointRadius,
                                      onChanged: (value) => tmpHolder.pointRadius = value,
                                      min: 0.0,
                                      max: 10.0,
                                    ),
                                    Text("Line Type"),
                                    DropdownButton(
                                      value: tmpHolder.lineType,
                                      onChanged: (type) => tmpHolder.lineType = type,
                                      items: <LineType>[SolidLine(), DashedLine()]
                                          .map<DropdownMenuItem<LineType>>((type) => DropdownMenuItem(value: type, child: Text(type.toString()),)).toList(),
                                    )
                                  ],
                                ),
                                Divider(),
                                Column(
                                  children: <Widget>[
                                    Text("Magnification Glass Zoom"),
                                    Slider(
                                      value: tmpHolder.magnificationZoomFactor,
                                      onChanged: (value) => tmpHolder.magnificationZoomFactor = value,
                                      min: 1.0,
                                      max: 10.0,
                                    ),
                                    Text("Magnification Color"),
                                    _getColorPickerButton(context, "Pick Color", "Magnification Color", tmpHolder.magnificationColor, (color) => tmpHolder.magnificationColor = color),
                                    Text("Magnification Glass Size"),
                                    Slider(
                                      value: tmpHolder.magnificationRadius,
                                      onChanged: (value) => tmpHolder.magnificationRadius = value,
                                      min: 1.0,
                                      max: 100.0,
                                    ),
                                    Text("Magnification Circle Thickness"),
                                    Slider(
                                      value: tmpHolder.magnificationOuterCircleThickness,
                                      onChanged: (value) => tmpHolder.magnificationOuterCircleThickness = value,
                                      min: 0.0,
                                      max: 10.0,
                                    ),
                                    Text("Magnification Cross Hair Thickness"),
                                    Slider(
                                      value: tmpHolder.magnificationCrossHairThickness,
                                      onChanged: (value) => tmpHolder.magnificationCrossHairThickness = value,
                                      min: 0.0,
                                      max: 5.0,
                                    ),
                                  ],
                                ),
                                Divider(),
                                Column(
                                  children: <Widget>[
                                    Text("Distance Text Color"),
                                    _getColorPickerButton(context, "Pick Color", "Distance Text Color", tmpHolder.distanceColor, (color) => tmpHolder.distanceColor),
                                    Text("Num Decimal Places"),
                                    Slider(
                                      value: tmpHolder.numDecimalPlaces.toDouble(),
                                      onChanged: (value) => tmpHolder.numDecimalPlaces = value.round(),
                                      min: 0,
                                      max: 5,
                                      divisions: 1,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Text("Show Tolerance"),
                                        Checkbox(
                                          value: tmpHolder.showTolerance,
                                          onChanged: (value) => tmpHolder.showTolerance = value,
                                        ),
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            FlatButton(
                                child: Text("Cancel"),
                                onPressed: () {
                                  tmpHolder = holder;
                                  Navigator.of(context).pop();
                                }
                            ),
                            FlatButton(
                              child: Text("Apply"),
                              onPressed: () {
                                setState(() {
                                  holder = tmpHolder;
                                });
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                        ),
                      ),
                );
              },
              icon: Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
      body: Center(
        child: Measurement(
          child: Image.asset("assets/images/example_portrait.png",),
          scale: 1 / 2.0,
//            magnificationZoomFactor: holder.magnificationZoomFactor,
          pointStyle: PointStyle(
//                dotColor: holder.pointColor,
//                dotRadius: holder.pointRadius,
            lineType: DashedLine(),
          ),
//            magnificationStyle: MagnificationStyle(
//              magnificationColor: holder.magnificationColor,
//              magnificationRadius: holder.magnificationRadius,
//              outerCircleThickness: holder.magnificationOuterCircleThickness,
//              crossHairThickness: holder.magnificationCrossHairThickness,
//            ),
//            distanceStyle: DistanceStyle(
//              textColor: holder.distanceColor,
//              numDecimalPlaces: holder.numDecimalPlaces,
//              showTolerance: holder.showTolerance,
//            ),
          distanceCallback: distanceCallback,
          showDistanceOnLine: showDistanceOnLine,
          measure: measure,
        ),
      ),
    );
  }

  Widget _getColorPickerButton(BuildContext context, String buttonText, String dialogText, Color color, Function(Color) onChanged) {
    return FlatButton(
      child: Text(buttonText),
      color: color,
      onPressed: () =>
          showDialog(
            context: context,
            child: AlertDialog(
              title: Text(dialogText),
              content: ColorPicker(
                pickerColor: color,
                onColorChanged: onChanged,
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text("Apply"),
                  onPressed: () {
                    setState(() {});
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          ),
    );
  }
}

class _OptionsHolder {
  double magnificationZoomFactor = 2.0;

  Color pointColor = drawColor;
  double pointRadius = 1;
  LineType lineType = SolidLine();

  Color magnificationColor = drawColor;
  double magnificationRadius = 50;
  double magnificationOuterCircleThickness = 2;
  double magnificationCrossHairThickness = 1;

  Color distanceColor = drawColor;
  int numDecimalPlaces = 2;
  bool showTolerance = false;
}