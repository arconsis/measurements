import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:measurements/measurements.dart';

void main() {
  group("Zoom Level Calculator Unit Test", () {
    final dpm = 20.0;
    final viewWidth = 800.0;
    final documentWidthInMM = 200.0;

    final MethodChannel channel = MethodChannel('measurements');

    WidgetsFlutterBinding.ensureInitialized();

    setUpAll(() {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == "getPhysicalPixelsPerMM") {
          return dpm;
        } else {
          return -1;
        }
      });
    });

    tearDownAll(() {
      channel.setMockMethodCallHandler(null);
    });

    test("getZoomLevel without scale", () async {
      final expectedZoomFactor = 5.0;

      double zoomFactor = await getZoomLevel(viewWidth, documentWidthInMM);

      expect(zoomFactor, expectedZoomFactor);
    });

    test("getZoomLevel for scaled view", () async {
      final expectedZoomFactor = 10.0;

      double zoomFactor = await getZoomLevel(viewWidth, documentWidthInMM, scaleOfDisplayedObject: 1 / 2.0);

      expect(zoomFactor, expectedZoomFactor);
    });
  });
}