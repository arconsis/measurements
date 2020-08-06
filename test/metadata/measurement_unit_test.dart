/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'package:flutter_test/flutter_test.dart';
import 'package:document_measure/document_measure.dart';

void main() {
  final differenceThreshold = 0.0000001;

  group('Testing measurement conversions', () {
    group('Testing conversions from meter to others', () {
      final meter = Meter(1);

      test('meter to millimeter', () {
        expect(meter
            .convertToMillimeter()
            .value, equals(1000));
      });

      test('meter to inch', () {
        expect(meter
            .convertToInch()
            .value - 39.3700787, lessThan(differenceThreshold));
      });

      test('meter to foot', () {
        expect(meter
            .convertToFoot()
            .value - 3.2808399, lessThan(differenceThreshold));
      });

      test('meter to meter', () {
        expect(meter
            .convertToMeter()
            .value, equals(1));
      });
    });

    group('Testing conversions from millimeter to others', () {
      final millimeter = Millimeter(1);

      test('millimeter to meter', () {
        expect(millimeter
            .convertToMeter()
            .value, equals(0.001));
      });

      test('millimeter to inch', () {
        expect(millimeter
            .convertToInch()
            .value - 0.0393700787, lessThan(differenceThreshold));
      });

      test('millimeter to foot', () {
        expect(millimeter
            .convertToFoot()
            .value - 0.0032808399, lessThan(differenceThreshold));
      });

      test('millimeter to millimeter', () {
        expect(millimeter
            .convertToMillimeter()
            .value, equals(1));
      });
    });

    group('Testing conversions from inch to others', () {
      final inch = Inch(1);

      test('inch to meter', () {
        expect(inch
            .convertToMeter()
            .value, equals(0.0254));
      });

      test('inch to millimeter', () {
        expect(inch
            .convertToMillimeter()
            .value, equals(25.4));
      });

      test('inch to foot', () {
        expect(inch
            .convertToFoot()
            .value - 0.0833333333, lessThan(differenceThreshold));
      });

      test('inch to inch', () {
        expect(inch
            .convertToInch()
            .value, equals(1));
      });
    });

    group('Testing conversions from foot to others', () {
      final foot = Foot(1);

      test('foot to meter', () {
        expect(foot
            .convertToMeter()
            .value, equals(0.3048));
      });

      test('foot to millimeter', () {
        expect(foot
            .convertToMillimeter()
            .value, equals(304.8));
      });

      test('foot to inch', () {
        expect(foot
            .convertToInch()
            .value, equals(12));
      });

      test('foot to foot', () {
        expect(foot
            .convertToFoot()
            .value, equals(1));
      });
    });
  });
}