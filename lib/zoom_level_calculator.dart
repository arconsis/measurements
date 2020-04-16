import 'package:flutter/services.dart';

Future<double> getZoomLevel(
    double viewWidthInLogicalPixels, double documentWidthInMM,
    {double scaleOfDisplayedObject = 1}) async {
  double dpm = await MethodChannel("measurements")
      .invokeMethod("getPhysicalPixelsPerMM");

  double screenWidth = viewWidthInLogicalPixels / dpm;

  return documentWidthInMM / (screenWidth * scaleOfDisplayedObject);
} // 132: this is nowhere used
