#import "MeasurePlugin.h"
#if __has_include(<measure/measure-Swift.h>)
#import <measure/measure-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "measure-Swift.h"
#endif

@implementation MeasurePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMeasurePlugin registerWithRegistrar:registrar];
}
@end
