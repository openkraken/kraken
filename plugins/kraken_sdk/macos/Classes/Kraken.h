#import <FlutterMacOS/FlutterMacOS.h>
#import "Kraken.h"
#import "KrakenSDKPlugin.h"

typedef void(^MethodHandler)(FlutterMethodCall*, FlutterResult);

@interface Kraken : NSObject

+ (Kraken*) instanceByBinaryMessenger: (NSObject<FlutterBinaryMessenger>*) messenger;

@property NSString* bundleUrl;
@property FlutterEngine* flutterEngine;
@property FlutterMethodChannel* channel;
@property MethodHandler methodHandler;

- (instancetype)initWithFlutterEngine: (FlutterEngine*) engine;

- (NSString*) getUrl;

- (void) loadUrl: (NSString*)url;

- (void) reload;

- (void) reloadWithUrl: (NSString*) url;

- (void) setMethodHandler: (MethodHandler) handler;

- (void) invokeMethod: (NSString *)method arguments:(nullable id) arguments;

- (void) _handleMethodCall:(FlutterMethodCall* _Nonnull)call result:(FlutterResult _Nonnull )result;
@end
