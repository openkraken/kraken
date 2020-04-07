#import <Flutter/Flutter.h>

@interface KrakenSDKPlugin : NSObject<FlutterPlugin>

@property NSObject<FlutterPluginRegistrar> *registrar;

- (instancetype) initWithRegistrar: (NSObject<FlutterPluginRegistrar>*)registrar;

@end
