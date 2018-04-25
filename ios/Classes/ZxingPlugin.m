#import "ZxingPlugin.h"
#import <zxing/zxing-Swift.h>

@implementation ZxingPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftZxingPlugin registerWithRegistrar:registrar];
}
@end
