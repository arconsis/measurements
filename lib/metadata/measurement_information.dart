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

abstract class UnitOfMeasurement extends Equatable {
  const UnitOfMeasurement();

  String getAbbreviation();
}

class UnitMeter extends UnitOfMeasurement {
  @override
  String getAbbreviation() {
    return "m";
  }

  @override
  String toString() {
    return "Meter";
  }

  @override
  List<Object> get props => [];
}

class UnitMillimeter extends UnitOfMeasurement {
  const UnitMillimeter();

  @override
  String getAbbreviation() {
    return "mm";
  }

  @override
  String toString() {
    return "Millimeter";
  }

  @override
  List<Object> get props => [];
}

class UnitFoot extends UnitOfMeasurement {
  @override
  String getAbbreviation() {
    return "ft";
  }

  @override
  String toString() {
    return "Foot";
  }

  @override
  List<Object> get props => [];
}

class UnitInch extends UnitOfMeasurement {
  @override
  String getAbbreviation() {
    return "in";
  }

  @override
  String toString() {
    return "Inch";
  }

  @override
  List<Object> get props => [];
}

class MeasurementInformation extends Equatable {
  final double scale;
  final LengthUnit documentWidthInLengthUnits;
  final UnitOfMeasurement unitOfMeasurement;

  const MeasurementInformation({
    this.scale = 1.0,
    this.documentWidthInLengthUnits = const Millimeter(210.0),
    this.unitOfMeasurement = const UnitMillimeter(),
  });

  double get documentWidthInUnitOfMeasurement {
    if (unitOfMeasurement is UnitMeter) {
      return documentWidthInLengthUnits.convertToMeter();
    } else if (unitOfMeasurement is UnitMillimeter) {
      return documentWidthInLengthUnits.convertToMillimeter();
    } else if (unitOfMeasurement is UnitFoot) {
      return documentWidthInLengthUnits.convertToFoot();
    } else if (unitOfMeasurement is UnitInch) {
      return documentWidthInLengthUnits.convertToInch();
    } else {
      return 0.0;
    }
  }

  @override
  List<Object> get props => [scale, documentWidthInLengthUnits, unitOfMeasurement];

  @override
  String toString() {
    return super.toString() + " scale: $scale, documentWidth: $documentWidthInLengthUnits, unitOfMeasurement: $unitOfMeasurement";
  }
}