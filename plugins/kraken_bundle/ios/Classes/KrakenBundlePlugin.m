#import "KrakenBundlePlugin.h"
#import "BundleManager.h"

@implementation KrakenBundlePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"kraken_bundle"
            binaryMessenger:[registrar messenger]];
  KrakenBundlePlugin* instance = [[KrakenBundlePlugin alloc] init];
  [[BundleManager shareBundleManager] onAttach:instance channel:channel];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getBundleUrl" isEqualToString:call.method]) {
    result([[BundleManager shareBundleManager] getBundleUrl]);
  } else if([@"getZipBundleUrl" isEqualToString:call.method]) {
    result([[BundleManager shareBundleManager] getZipBundleUrl]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}
@end
