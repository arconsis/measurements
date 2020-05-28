import 'package:flutter_test/flutter_test.dart';
import 'package:measurements/metadata/measurement_information.dart';

void main() {
  final differenceThreshold = 0.0000001;

  group("Testing measurement conversions", () {
    group("Testing conversions from meter to others", () {
      final meter = Meter(1);

      test("meter to millimeter", () {
        expect(meter.convertToMillimeter(), equals(1000));
      });

      test("meter to inch", () {
        expect(meter.convertToInch() - 39.3700787, lessThan(differenceThreshold));
      });

      test("meter to foot", () {
        expect(meter.convertToFoot() - 3.2808399, lessThan(differenceThreshold));
      });

      test("meter to meter", () {
        expect(meter.convertToMeter(), equals(1));
      });
    });

    group("Testing conversions from millimeter to others", () {
      final millimeter = Millimeter(1);

      test("millimeter to meter", () {
        expect(millimeter.convertToMeter(), equals(0.001));
      });

      test("millimeter to inch", () {
        expect(millimeter.convertToInch() - 0.0393700787, lessThan(differenceThreshold));
      });

      test("millimeter to foot", () {
        expect(millimeter.convertToFoot() - 0.0032808399, lessThan(differenceThreshold));
      });

      test("millimeter to millimeter", () {
        expect(millimeter.convertToMillimeter(), equals(1));
      });
    });

    group("Testing conversions from inch to others", () {
      final inch = Inch(1);

      test("inch to meter", () {
        expect(inch.convertToMeter(), equals(0.0254));
      });

      test("inch to millimeter", () {
        expect(inch.convertToMillimeter(), equals(25.4));
      });

      test("inch to foot", () {
        expect(inch.convertToFoot() - 0.0833333333, lessThan(differenceThreshold));
      });

      test("inch to inch", () {
        expect(inch.convertToInch(), equals(1));
      });
    });

    group("Testing conversions from foot to others", () {
      final foot = Foot(1);

      test("foot to meter", () {
        expect(foot.convertToMeter(), equals(0.3048));
      });

      test("foot to millimeter", () {
        expect(foot.convertToMillimeter(), equals(304.8));
      });

      test("foot to inch", () {
        expect(foot.convertToInch(), equals(12));
      });

      test("foot to foot", () {
        expect(foot.convertToFoot(), equals(1));
      });
    });
  });
}