import Flutter
import UIKit

public class SwiftMeasurePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "measure", binaryMessenger: registrar.messenger())
    let instance = SwiftMeasurementsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if (call.method == "getPhysicalPixelsPerInch") {
        result(UIScreen.main.nativeScale)
    } else {
      result(nil)
    }
  }
}
