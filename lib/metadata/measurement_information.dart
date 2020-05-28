import 'package:equatable/equatable.dart';

abstract class LengthUnit extends Equatable {
  final double value;

  const LengthUnit(this.value);

  double convertToMillimeter();

  double convertToMeter();

  double convertToInch();

  double convertToFoot();

  @override
  List<Object> get props => [value];
}

class Meter extends LengthUnit {
  Meter(double meters) : super(meters);

  @override
  double convertToFoot() => value / 0.3048;

  @override
  double convertToInch() => value / 0.0254;

  @override
  double convertToMeter() => value;

  @override
  double convertToMillimeter() => value * 1000;

  @override
  String toString() {
    return super.toString() + " ${value}m";
  }
}

class Millimeter extends LengthUnit {
  const Millimeter(double millimeters) : super(millimeters);

  @override
  double convertToFoot() => value / 304.8;

  @override
  double convertToInch() => value / 25.4;

  @override
  double convertToMeter() => value / 1000;

  @override
  double convertToMillimeter() => value;

  @override
  String toString() {
    return super.toString() + " ${value}mm";
  }
}

class Inch extends LengthUnit {
  Inch(double inches) : super(inches);

  @override
  double convertToFoot() => value / 12;

  @override
  double convertToInch() => value;

  @override
  double convertToMeter() => value * 0.0254;

  @override
  double convertToMillimeter() => value * 25.4;

  @override
  String toString() {
    return super.toString() + " ${value}in";
  }
}

class Foot extends LengthUnit {
  Foot(double feet) : super(feet);

  @override
  double convertToFoot() => value;

  @override
  double convertToInch() => value * 12;

  @override
  double convertToMeter() => value * 0.3048;

  @override
  double convertToMillimeter() => value * 304.8;

  @override
  String toString() {
    return super.toString() + " ${value}ft";
  }
}

enum UnitOfMeasurement {
  METER,
  MILLIMETER,
  INCH,
  FOOT
}

class MeasurementInformation extends Equatable {
  final double scale;
  final LengthUnit documentWidthInLengthUnits;
  final UnitOfMeasurement unitOfMeasurement;

  const MeasurementInformation({
    this.scale = 1.0,
    this.documentWidthInLengthUnits = const Millimeter(210.0),
    this.unitOfMeasurement = UnitOfMeasurement.MILLIMETER
  });

  double get documentWidthInUnitOfMeasurement {
    switch (unitOfMeasurement) {
      case UnitOfMeasurement.METER:
        return documentWidthInLengthUnits.convertToMeter();
      case UnitOfMeasurement.MILLIMETER:
        return documentWidthInLengthUnits.convertToMillimeter();
      case UnitOfMeasurement.INCH:
        return documentWidthInLengthUnits.convertToInch();
      case UnitOfMeasurement.FOOT:
        return documentWidthInLengthUnits.convertToFoot();
    }

    return 0.0;
  }

  @override
  List<Object> get props => [scale, documentWidthInLengthUnits, unitOfMeasurement];

  @override
  String toString() {
    return super.toString() + " scale: $scale, documentWidth: $documentWidthInLengthUnits, unitOfMeasurement: $unitOfMeasurement";
  }
}