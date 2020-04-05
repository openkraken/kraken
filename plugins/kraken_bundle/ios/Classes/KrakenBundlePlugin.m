#import "KrakenBundlePlugin.h"
#import "KrakenBundleManager.h"

@implementation KrakenBundlePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"kraken_bundle"
            binaryMessenger:[registrar messenger]];
  KrakenBundlePlugin* instance = [[KrakenBundlePlugin alloc] init];
  [[KrakenBundleManager shareBundleManager] onAttach:instance channel:channel];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getBundleUrl" isEqualToString:call.method]) {
    result([[KrakenBundleManager shareBundleManager] getBundleUrl]);
  } else if([@"getZipBundleUrl" isEqualToString:call.method]) {
    result([[KrakenBundleManager shareBundleManager] getZipBundleUrl]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}
@end
