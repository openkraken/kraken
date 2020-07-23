#import <Flutter/Flutter.h>

#define NAME_METHOD_SPLIT @"@≥_≤@"

@interface KrakenSDKPlugin : NSObject<FlutterPlugin>

@property NSObject<FlutterPluginRegistrar> *registrar;

- (instancetype) initWithRegistrar: (NSObject<FlutterPluginRegistrar>*)registrar;

+ (FlutterMethodChannel *) getMethodChannel;

@end
