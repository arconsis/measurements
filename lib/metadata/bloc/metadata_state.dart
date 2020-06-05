///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

import 'package:equatable/equatable.dart';

class MetadataState extends Equatable {
  final bool measure;

  MetadataState(this.measure);

  @override
  List<Object> get props => [measure];

  @override
  String toString() {
    return super.toString() + " measure: $measure";
  }
}