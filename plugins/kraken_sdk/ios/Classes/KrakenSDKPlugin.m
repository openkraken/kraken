#import "Kraken.h"
#import "KrakenSDKPlugin.h"

@implementation KrakenSDKPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  NSObject<FlutterBinaryMessenger>* messager = [registrar messenger];
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"kraken_sdk"
            binaryMessenger:messager];
  
  KrakenSDKPlugin* instance = [[KrakenSDKPlugin alloc] initWithRegistrar: registrar];
  
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype) initWithRegistrar: (NSObject<FlutterPluginRegistrar>*)registrar {
  self = [super init];
  self.registrar = registrar;
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getUrl" isEqualToString:call.method]) {
    Kraken* krakenInstance = [Kraken instanceByBinaryMessenger: [self.registrar messenger]];
    if (krakenInstance != nil) {
      result([krakenInstance getUrl]);
    } else {
      result(nil);
    }
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
