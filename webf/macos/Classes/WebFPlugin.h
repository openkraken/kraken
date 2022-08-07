#import <FlutterMacOS/FlutterMacOS.h>

#define NAME_METHOD_SPLIT @"!!"

@interface WebFPlugin : NSObject<FlutterPlugin>

@property NSObject<FlutterPluginRegistrar> *registrar;
@property FlutterMethodChannel *channel;

- (instancetype) initWithRegistrar: (NSObject<FlutterPluginRegistrar>*)registrar;

+ (FlutterMethodChannel *) getMethodChannel;

@end
