#import <Flutter/Flutter.h>
#import "Kraken.h"
#import "KrakenSDKPlugin.h"

@interface Kraken : NSObject

+ (Kraken*) instanceByBinaryMessenger: (NSObject<FlutterBinaryMessenger>*) messenger;

@property NSString* bundleUrl;
@property FlutterEngine* flutterEngine;
@property FlutterMethodChannel* channel;

- (instancetype)initWithFlutterEngine: (FlutterEngine*) engine;

- (NSString*) getUrl;

- (void) loadUrl:(NSString*)url;

- (void) reload;

- (void) reloadWithUrl: (NSString*) url;

@end
