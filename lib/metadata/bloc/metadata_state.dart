import 'package:equatable/equatable.dart';

class MetadataState extends Equatable {
  final bool measure;
  final double magnificationRadius;

  MetadataState(this.measure, this.magnificationRadius);

  @override
  List<Object> get props => [measure, magnificationRadius];

  @override
  String toString() {
    return super.toString() + " measure: $measure magnificationRadius: $magnificationRadius";
  }
}