#import "KrakenMethodChannelPlugin.h"
#if __has_include(<kraken_method_channel/kraken_method_channel-Swift.h>)
#import <kraken_method_channel/kraken_method_channel-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "kraken_method_channel-Swift.h"
#endif

@implementation KrakenMethodChannelPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftKrakenMethodChannelPlugin registerWithRegistrar:registrar];
}
@end
