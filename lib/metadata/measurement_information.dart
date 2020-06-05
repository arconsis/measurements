import 'package:equatable/equatable.dart';

abstract class LengthUnit extends Equatable {
  final double value;

  const LengthUnit(this.value);

  Millimeter convertToMillimeter();

  Meter convertToMeter();

  Inch convertToInch();

  Foot convertToFoot();

  LengthUnit convertFrom(LengthUnit lengthUnit);

  String getAbbreviation();

  LengthUnit operator /(double value);

  LengthUnit operator *(double value);

  @override
  List<Object> get props => [value];
}

class Meter extends LengthUnit {
  Meter.asUnit() : super(1);

  Meter(double meters) : super(meters);

  @override
  Foot convertToFoot() => Foot(value / 0.3048);

  @override
  Inch convertToInch() => Inch(value / 0.0254);

  @override
  Meter convertToMeter() => Meter(value);

  @override
  Millimeter convertToMillimeter() => Millimeter(value * 1000);

  @override
  Meter convertFrom(LengthUnit lengthUnit) => lengthUnit.convertToMeter();

  @override
  String toString() => super.toString() + " ${value}m";

  @override
  String getAbbreviation() => "m";

  @override
  Meter operator *(double value) => Meter(this.value * value);

  @override
  Meter operator /(double value) => Meter(this.value / value);
}

class Millimeter extends LengthUnit {
  const Millimeter.asUnit() : super(1);

  const Millimeter(double millimeters) : super(millimeters);

  @override
  Foot convertToFoot() => Foot(value / 304.8);

  @override
  Inch convertToInch() => Inch(value / 25.4);

  @override
  Meter convertToMeter() => Meter(value / 1000);

  @override
  Millimeter convertToMillimeter() => Millimeter(value);

  @override
  Millimeter convertFrom(LengthUnit lengthUnit) => lengthUnit.convertToMillimeter();

  @override
  String toString() => super.toString() + " ${value}mm";

  @override
  String getAbbreviation() => "mm";

  @override
  Millimeter operator *(double value) => Millimeter(this.value * value);

  @override
  Millimeter operator /(double value) => Millimeter(this.value / value);
}

class Inch extends LengthUnit {
  Inch.asUnit() : super(1);

  Inch(double inches) : super(inches);

  @override
  Foot convertToFoot() => Foot(value / 12);

  @override
  Inch convertToInch() => Inch(value);

  @override
  Meter convertToMeter() => Meter(value * 0.0254);

  @override
  Millimeter convertToMillimeter() => Millimeter(value * 25.4);

  @override
  Inch convertFrom(LengthUnit lengthUnit) => lengthUnit.convertToInch();

  @override
  String toString() => super.toString() + " ${value}in";

  @override
  String getAbbreviation() => "in";

  @override
  Inch operator *(double value) => Inch(this.value * value);

  @override
  Inch operator /(double value) => Inch(this.value / value);
}

class Foot extends LengthUnit {
  Foot.asUnit() : super(1);

  Foot(double feet) : super(feet);

  @override
  Foot convertToFoot() => Foot(value);

  @override
  Inch convertToInch() => Inch(value * 12);

  @override
  Meter convertToMeter() => Meter(value * 0.3048);

  @override
  Millimeter convertToMillimeter() => Millimeter(value * 304.8);

  @override
  Foot convertFrom(LengthUnit lengthUnit) => lengthUnit.convertToFoot();

  @override
  String toString() => super.toString() + " ${value}ft";

  @override
  String getAbbreviation() => "ft";

  @override
  Foot operator *(double value) => Foot(this.value * value);

  @override
  Foot operator /(double value) => Foot(this.value / value);
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

  LengthUnit get documentWidthInUnitOfMeasurement => targetLengthUnit.convertFrom(documentWidthInLengthUnits);

  String get unitAbbreviation => targetLengthUnit.getAbbreviation();

  @override
  List<Object> get props => [scale, documentWidthInLengthUnits, targetLengthUnit];

  @override
  String toString() {
    return super.toString() + " scale: $scale, documentWidth: $documentWidthInLengthUnits, targetLengthUnit: $targetLengthUnit";
  }
}