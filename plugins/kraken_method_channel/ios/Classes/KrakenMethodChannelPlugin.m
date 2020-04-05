#import "KrakenMethodChannelPlugin.h"
#import "KrakenMethodChannel.h"

@implementation KrakenMethodChannelPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"kraken_method_channel"
            binaryMessenger:[registrar messenger]];
  KrakenMethodChannelPlugin* instance = [[KrakenMethodChannelPlugin alloc] init];
  [[KrakenMethodChannel sharedMethodChannel] onAttach:instance channel:channel];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  [[KrakenMethodChannel sharedMethodChannel] handleMessageCall:call result:result];
}
@end

