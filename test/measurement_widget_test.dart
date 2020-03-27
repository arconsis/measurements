import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:measurements/measurements.dart';
import 'package:measurements/overlay/measure_area.dart';

Type typeOf<T>() => T;

final imageWidth = 800.0;
final imageHeight = 600.0;
final imageChild = Image.asset(
  "assets/images/example_portrait.png",
  package: "measurements",
  width: imageWidth,
  height: imageHeight,
);

void main() {
  testWidgets("Measurement should show child without extras", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MeasurementView(
          child: imageChild,
        ),
      ),
    ));

    final imageFinder = find.byWidget(imageChild);
    final measureFinder = find.byType(typeOf<MeasureArea>());

    expect(imageFinder, findsOneWidget);
    expect(measureFinder, findsNothing);

    checkWidgetHasCorrectSize(tester.getSize(imageFinder));
  });

  testWidgets("Measurement should show MeasureArea", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MeasurementView(
          child: imageChild,
          measure: true,
        ),
      ),
    ));

    final imageFinder = find.byWidget(imageChild);
    final measureFinder = find.byType(typeOf<MeasureArea>());
    final paintFinder = find.byType(typeOf<CustomPaint>());

    print(tester.getSize(paintFinder));

    expect(imageFinder, findsOneWidget);
    expect(measureFinder, findsOneWidget);
    expect(paintFinder, findsOneWidget); // there seems to be a CustomPaint in the default widget tree

    checkWidgetHasCorrectSize(tester.getSize(imageFinder));
    checkWidgetHasCorrectSize(tester.getSize(measureFinder));
  });

  testWidgets("Measurement should show three Points", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MeasurementView(
          child: imageChild,
          measure: true,
        ),
      ),
    ));

    final imageFinder = find.byWidget(imageChild);
    final measureFinder = find.byType(typeOf<MeasureArea>());

    expect(imageFinder, findsOneWidget);
    expect(measureFinder, findsOneWidget);

    checkWidgetHasCorrectSize(tester.getSize(imageFinder));
    checkWidgetHasCorrectSize(tester.getSize(measureFinder));

    final gesture = await tester.startGesture(Offset(10, 20));
    await gesture.up();

    await gesture.down(Offset(90, 20));
    await gesture.up();

    await gesture.down(Offset(10, 150));
    await gesture.up();

    await tester.pumpAndSettle();

    final paintFinder = find.byType(typeOf<CustomPaint>(),);

    expect(paintFinder, findsNWidgets(3));
  });

  testWidgets("Measurement should show three points after moving one point", (WidgetTester tester) async {
    expect("Not implemented yet", "Implemented");
  });

  testWidgets("Measurement should show four points after moving one point and setting another one at that position", (WidgetTester tester) async {
    expect("Not implemented yet", "Implemented");
  });
}

void checkWidgetHasCorrectSize(Size size) {
  expect(size.width, equals(imageWidth));
  expect(size.height, equals(imageHeight));
}