import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:measurements/measurements.dart';
import 'package:measurements/overlay/measure_area.dart';

Type typeOf<T>() => T;

void main() {
  testWidgets("Measurement should show child without extras", (WidgetTester tester) async {
    final imageKey = GlobalKey();
    final child = Image.asset("assets/images/example_portrait.png", key: imageKey, package: "measurements", width: 100, height: 200,);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MeasurementView(
          child: child,
        ),
      ),
    ));

    final imageFinder = find.byWidget(child);
    final measureFinder = find.byType(typeOf<MeasureArea>());

    expect(imageFinder, findsOneWidget);
    expect(measureFinder, findsNothing);

    final renderBox = imageKey.currentContext.findRenderObject() as RenderBox;
    expect(renderBox.size.width, greaterThan(0));
    expect(renderBox.size.height, greaterThan(0));
  });

  testWidgets("Measurement should show MeasureArea", (WidgetTester tester) async {
    final imageKey = GlobalKey();
    final child = Image.asset("assets/images/example_portrait.png", key: imageKey, package: "measurements", width: 100, height: 200,);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: MeasurementView(
            child: child,
            measure: true,
          ),
        ),
      ),
    ));

    final imageFinder = find.byWidget(child);
    final measureFinder = find.byType(typeOf<MeasureArea>());

    expect(imageFinder, findsOneWidget);
    expect(measureFinder, findsOneWidget);

    final renderBox = imageKey.currentContext.findRenderObject() as RenderBox;
    expect(renderBox.size.width, greaterThan(0));
    expect(renderBox.size.height, greaterThan(0));
  });
}