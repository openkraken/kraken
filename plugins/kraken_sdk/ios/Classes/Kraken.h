#import <Flutter/Flutter.h>
#import "Kraken.h"
#import "KrakenSDKPlugin.h"

@interface Kraken : NSObject

+ (Kraken*) get: (NSString*) isolateId;

@property NSString* bundleUrl;
@property FlutterEngine* flutterEngine;
@property FlutterMethodChannel* channel;

- (NSString*) getUrl;

- (void) loadUrl:(NSString*)url;

- (void) reload;

- (void) reloadWithUrl: (NSString*) url;

@end
