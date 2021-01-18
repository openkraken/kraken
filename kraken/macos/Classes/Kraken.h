#import <FlutterMacOS/FlutterMacOS.h>
#import "Kraken.h"
#import "KrakenPlugin.h"

typedef void(^MethodHandler)(FlutterMethodCall* _Nonnull , FlutterResult _Nonnull);

@interface Kraken : NSObject

+ (Kraken* _Nonnull) instanceByBinaryMessenger: (NSObject<FlutterBinaryMessenger>* _Nonnull) messenger;

@property NSString* _Nullable bundleUrl;
@property FlutterEngine* _Nonnull flutterEngine;
@property FlutterMethodChannel* _Nullable channel;
@property MethodHandler _Nullable methodHandler;

- (instancetype _Nonnull)initWithFlutterEngine: (FlutterEngine* _Nonnull) engine;

- (NSString* _Nullable) getUrl;

- (void) loadUrl: (NSString* _Nonnull)url;

- (void) reload;

- (void) reloadWithUrl: (NSString* _Nonnull) url;

- (void) registerMethodCallHandler: (MethodHandler _Nonnull) handler;

- (void) invokeMethod: (NSString* _Nonnull)method arguments:(nullable id) arguments;

- (void) _handleMethodCall:(FlutterMethodCall* _Nonnull)call result:(FlutterResult _Nonnull )result;
@end
