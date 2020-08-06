import Flutter
import UIKit

public class SwiftMeasurePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "measure", binaryMessenger: registrar.messenger())
        let instance = SwiftMeasurePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "getPhysicalPixelsPerInch") {
            var ppi: double_t
            
            switch UIDevice().name {
            case "iPhone X", "iPhone Xs", "iPhone 11 Pro", "iPhone 11 Pro Max":
                ppi = 458.0
            case "iPhone 6 Plus", "iPhone 6s Plus", "iPhone 7 Plus", "iPhone 8 Plus":
                ppi = 401.0
            case "iPhone 4s", "iPhone 5", "iPhone 5s", "iPhone 5c", "iPhone SE (1st generation)", "iPhone 6", "iPhone 6s", "iPhone 7", "iPhone 8", "iPhone 11", "iPhone Xʀ", "iPhone SE (2nd generation)", "iPad mini 2", "iPad mini 3", "iPad mini 4", "iPad mini (5th generation)":
                ppi = 326.0
            case "iPad Retina", "iPad Air", "iPad Air 2", "iPad Pro (9.7-inch)", "iPad Pro (12.9-inch)", "iPad (5th generation)", "iPad Pro (12.9-inch) (2nd generation)", "iPad (10.5-inch)", "iPad (6th generation)", "iPad (7th generation)", "iPad Pro (11-inch) (1st generation)", "iPad Pro (12.9-inch) (3rd generation)", "iPad Pro (11-inch) (2nd generation)", "iPad Pro (12.9-inch) (4th generation)", "iPad Air (3rd generation)":
                ppi = 264.0
            case "iPad 2":
                ppi = 132
            default:
                ppi = 326.0
            }
            
            result(ppi)
        } else {
            result(nil)
        }
    }
}
