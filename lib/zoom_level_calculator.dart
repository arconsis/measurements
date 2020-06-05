///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

import 'package:flutter/services.dart';

class ZoomLevelCalculator {
  static Future<double> getZoomLevel(double viewWidthInLogicalPixels, double documentWidthInMM, {double scaleOfDisplayedObject = 1}) async {
    double dpm = await MethodChannel("measurements").invokeMethod("getPhysicalPixelsPerMM");

    double screenWidth = viewWidthInLogicalPixels / dpm;

    return documentWidthInMM / (screenWidth * scaleOfDisplayedObject);
  }
}