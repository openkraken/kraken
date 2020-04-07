#import <FlutterMacOS/FlutterMacOS.h>

@interface KrakenSDKPlugin : NSObject<FlutterPlugin>

@property NSObject<FlutterPluginRegistrar> *registrar;

- (instancetype) initWithRegistrar: (NSObject<FlutterPluginRegistrar>*)registrar;

@end
