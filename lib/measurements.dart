import 'dart:async';

import 'package:flutter/services.dart';

class Measurements {
  static const MethodChannel _channel =
      const MethodChannel('measurements');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
