#import "Kraken.h"
#import "KrakenSDKPlugin.h"

@implementation KrakenSDKPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"kraken_sdk"
            binaryMessenger:[registrar messenger]];
  
  KrakenSDKPlugin* instance = [[KrakenSDKPlugin alloc] init];
  
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"setIsolateId" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* isolateId = argsMap[@"isolateId"];
    if (isolateId != nil) {
      self.isolateId = isolateId;
    }
    result(nil);
  } else if ([@"getUrl" isEqualToString:call.method]) {
    Kraken* krakenInstance = [Kraken get:self.isolateId];
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
