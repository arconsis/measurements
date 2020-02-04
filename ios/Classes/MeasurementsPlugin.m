#import "MeasurementsPlugin.h"
#if __has_include(<measurements/measurements-Swift.h>)
#import <measurements/measurements-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "measurements-Swift.h"
#endif

@implementation MeasurementsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMeasurementsPlugin registerWithRegistrar:registrar];
}
@end
