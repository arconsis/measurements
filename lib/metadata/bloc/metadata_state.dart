///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

import 'package:equatable/equatable.dart';
import 'package:photo_view/photo_view.dart';

class MetadataState extends Equatable {
  final PhotoViewController controller;

  MetadataState(this.controller);

  @override
  List<Object> get props => [controller];

  @override
  String toString() {
    return super.toString() + " PhotoViewController: $controller";
  }
}