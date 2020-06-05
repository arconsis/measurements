import 'package:equatable/equatable.dart';

abstract class LengthUnit extends Equatable {
  final double value;

  const LengthUnit(this.value);

  double convertToMillimeter();

  double convertToMeter();

  double convertToInch();

  double convertToFoot();

  double convertFrom(LengthUnit lengthUnit);

  String getAbbreviation();

  @override
  List<Object> get props => [value];
}

class Meter extends LengthUnit {
  Meter.asUnit() : super(1);

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
  double convertFrom(LengthUnit lengthUnit) => lengthUnit.convertToMeter();

  @override
  String toString() => super.toString() + " ${value}m";

  @override
  String getAbbreviation() => "m";
}

class Millimeter extends LengthUnit {
  const Millimeter.asUnit() : super(1);

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
  double convertFrom(LengthUnit lengthUnit) => lengthUnit.convertToMillimeter();

  @override
  String toString() => super.toString() + " ${value}mm";

  @override
  String getAbbreviation() => "mm";
}

class Inch extends LengthUnit {
  Inch.asUnit() : super(1);

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
  double convertFrom(LengthUnit lengthUnit) => lengthUnit.convertToInch();

  @override
  String toString() => super.toString() + " ${value}in";

  @override
  String getAbbreviation() => "in";
}

class Foot extends LengthUnit {
  Foot.asUnit() : super(1);

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
  double convertFrom(LengthUnit lengthUnit) => lengthUnit.convertToFoot();

  @override
  String toString() => super.toString() + " ${value}ft";

  @override
  String getAbbreviation() => "ft";
}

class MeasurementInformation extends Equatable {
  final double scale;
  final LengthUnit documentWidthInLengthUnits;
  final LengthUnit targetLengthUnit;

  const MeasurementInformation({
    this.scale = 1.0,
    this.documentWidthInLengthUnits = const Millimeter(210.0),
    this.targetLengthUnit = const Millimeter.asUnit(),
  });

  double get documentWidthInUnitOfMeasurement => targetLengthUnit.convertFrom(documentWidthInLengthUnits);

  String get unitAbbreviation => targetLengthUnit.getAbbreviation();

  @override
  List<Object> get props => [scale, documentWidthInLengthUnits, targetLengthUnit];

  @override
  String toString() {
    return super.toString() + " scale: $scale, documentWidth: $documentWidthInLengthUnits, targetLengthUnit: $targetLengthUnit";
  }
}