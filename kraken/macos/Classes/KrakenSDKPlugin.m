#import "Kraken.h"
#import "KrakenSDKPlugin.h"

static FlutterMethodChannel *methodChannel = nil;

@implementation KrakenSDKPlugin

+ (FlutterMethodChannel *) getMethodChannel {
  return methodChannel;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  NSObject<FlutterBinaryMessenger>* messager = [registrar messenger];
  FlutterMethodChannel* channel = [FlutterMethodChannel
                                   methodChannelWithName:@"kraken"
                                   binaryMessenger:messager];
  methodChannel = channel;
  
  KrakenSDKPlugin* instance = [[KrakenSDKPlugin alloc] initWithRegistrar: registrar];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype) initWithRegistrar: (NSObject<FlutterPluginRegistrar>*)registrar{
  self = [super init];
  self.registrar = registrar;
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSArray<NSString*> *group = [call.method componentsSeparatedByString:NAME_METHOD_SPLIT];
  NSString *name = group[0];
  NSString *method = group[1];
  Kraken* krakenInstance = [Kraken instanceByName:name];
  
  if (krakenInstance == nil) {
    result(nil);
    return;
  }
  
  if ([@"getUrl" isEqualToString:method]) {
    if (krakenInstance != nil) {
      result([krakenInstance getUrl]);
    } else {
      result(nil);
    }
  } else if ([@"invokeMethod" isEqualToString: method]) {
    FlutterMethodCall* callWrap = [FlutterMethodCall methodCallWithMethodName: call.arguments[@"method"] arguments: call.arguments[@"args"]];
    [krakenInstance _handleMethodCall:callWrap result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
