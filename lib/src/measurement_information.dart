/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// The [LengthUnits] allow us to offer different units for measurement and changing between them.
abstract class LengthUnit extends Equatable {
  final double value;

  const LengthUnit(this.value);

  @override
  String toString() => super.toString() + ' $value${getAbbreviation()}';

  @override
  List<Object> get props => [value];

  Millimeter convertToMillimeter() => Millimeter(value * millimeterFactor());

  Meter convertToMeter() => Meter(value * meterFactor());

  Inch convertToInch() => Inch(value * inchFactor());

  Foot convertToFoot() => Foot(value * footFactor());

  /// Returns the conversion factor of the current length unit to the target length [unit].
  ///
  /// The individual lengths are ignored, only the types matter.
  /// ```dart
  /// Meter(10).factorTo(Millimeter(20)); // 1000 (millimeter per meter)
  /// ```
  LengthUnit factorTo(LengthUnit unit) {
    switch (unit.runtimeType) {
      case Meter:
        return Meter(meterFactor());
      case Millimeter:
        return Millimeter(millimeterFactor());
      case Inch:
        return Inch(inchFactor());
      case Foot:
        return Foot(footFactor());
      default:
        return Meter(-1);
    }
  }

  /// Returns the current length expressed in the unit of the target length [unit].
  ///
  /// The length of the target unit is ignored, only its type matters.
  /// ```dart
  /// Meter(10).convertTo(Millimeter(5)); // 10.000 (millimeter)
  /// ```
  LengthUnit convertTo(LengthUnit unit) {
    switch (unit.runtimeType) {
      case Meter:
        return convertToMeter();
      case Millimeter:
        return convertToMillimeter();
      case Inch:
        return convertToInch();
      case Foot:
        return convertToFoot();
      default:
        return Meter(-1);
    }
  }

  double meterFactor();

  double millimeterFactor();

  double inchFactor();

  double footFactor();

  String getAbbreviation();

  LengthUnit operator /(double value);

  LengthUnit operator *(double value);
}

class Meter extends LengthUnit {
  Meter.asUnit() : super(1);

  Meter(double meters) : super(meters);

  @override
  double footFactor() => 1 / 0.3048;

  @override
  double inchFactor() => 1 / 0.0254;

  @override
  double meterFactor() => 1;

  @override
  double millimeterFactor() => 1000;

  @override
  String getAbbreviation() => 'm';

  @override
  Meter operator *(double value) => Meter(this.value * value);

  @override
  Meter operator /(double value) => Meter(this.value / value);
}

class Millimeter extends LengthUnit {
  const Millimeter.asUnit() : super(1);

  const Millimeter(double millimeters) : super(millimeters);

  @override
  double footFactor() => 1 / 304.8;

  @override
  double inchFactor() => 1 / 25.4;

  @override
  double meterFactor() => 1 / 1000;

  @override
  double millimeterFactor() => 1;

  @override
  String getAbbreviation() => 'mm';

  @override
  Millimeter operator *(double value) => Millimeter(this.value * value);

  @override
  Millimeter operator /(double value) => Millimeter(this.value / value);
}

class Inch extends LengthUnit {
  Inch.asUnit() : super(1);

  Inch(double inches) : super(inches);

  @override
  double footFactor() => 1 / 12;

  @override
  double inchFactor() => 1;

  @override
  double meterFactor() => 0.0254;

  @override
  double millimeterFactor() => 25.4;

  @override
  String getAbbreviation() => 'in';

  @override
  Inch operator *(double value) => Inch(this.value * value);

  @override
  Inch operator /(double value) => Inch(this.value / value);
}

class Foot extends LengthUnit {
  Foot.asUnit() : super(1);

  Foot(double feet) : super(feet);

  @override
  double footFactor() => 1;

  @override
  double inchFactor() => 12;

  @override
  double meterFactor() => 0.3048;

  @override
  double millimeterFactor() => 304.8;

  @override
  String getAbbreviation() => 'ft';

  @override
  Foot operator *(double value) => Foot(this.value * value);

  @override
  Foot operator /(double value) => Foot(this.value / value);
}

/// This contains the information about the document that is being displayed.
///
/// To change the result measurement unit change [targetLengthUnit].
class MeasurementInformation extends Equatable {
  /// The scale of the content in the displayed document.
  final double scale;

  /// The unit of measurement for the measurements of the user.
  final LengthUnit targetLengthUnit;

  final LengthUnit documentWidthInLengthUnits;
  final LengthUnit documentHeightInLengthUnits;

  const MeasurementInformation({
    @required this.documentWidthInLengthUnits,
    @required this.documentHeightInLengthUnits,
    this.scale = 1.0,
    this.targetLengthUnit = const Millimeter.asUnit(),
  });

  /// Default constructor for a DIN A4 document with a scale of 1 and Millimeters as the target unit.
  const MeasurementInformation.dinA4({
    this.scale = 1.0,
    this.documentWidthInLengthUnits = const Millimeter(210.0),
    this.documentHeightInLengthUnits = const Millimeter(297.0),
    this.targetLengthUnit = const Millimeter.asUnit(),
  });

  LengthUnit get documentToTargetFactor =>
      documentWidthInLengthUnits.factorTo(targetLengthUnit);

  LengthUnit get documentWidthInUnitOfMeasurement =>
      documentWidthInLengthUnits.convertTo(targetLengthUnit);

  @override
  List<Object> get props =>
      [scale, documentWidthInLengthUnits, targetLengthUnit];

  @override
  String toString() {
    return super.toString() +
        ' scale: $scale, documentWidth: $documentWidthInLengthUnits, documentHeight: $documentHeightInLengthUnits, targetLengthUnit: $targetLengthUnit';
  }
}
