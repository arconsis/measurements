import 'package:flutter/services.dart';

Future<double> getZoomLevel(double viewWidthInLogicalPixels, double documentWidthInMM,
    {double scaleOfDisplayedObject = 1}) async {
  double dpm = await MethodChannel("measurements")
      .invokeMethod("getPhysicalPixelsPerMM");

  double screenWidth = viewWidthInLogicalPixels / dpm;

  return documentWidthInMM / (screenWidth * scaleOfDisplayedObject);
} // 1432: this is nowhere used -> method for external use to get zoom factor for one to one size on display
