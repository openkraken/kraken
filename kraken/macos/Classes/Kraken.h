#import <FlutterMacOS/FlutterMacOS.h>
#import "Kraken.h"
#import "KrakenSDKPlugin.h"

typedef void(^MethodHandler)(FlutterMethodCall* _Nonnull , FlutterResult _Nonnull);

@interface Kraken : NSObject

+ (Kraken* _Nonnull) instanceByName: (NSString* _Nonnull) name;

@property NSString* _Nullable bundleUrl;
@property FlutterMethodChannel* _Nullable channel;
@property MethodHandler _Nullable methodHandler;
@property NSString* _Nonnull name;

- (instancetype _Nonnull) initWithName:(NSString* _Nonnull) name;

- (NSString* _Nullable) getUrl;

- (void) loadUrl: (NSString* _Nonnull)url;

- (void) reload;

- (void) reloadWithUrl: (NSString* _Nonnull) url; 

- (void) registerMethodCallHandler: (MethodHandler _Nonnull) handler;

- (void) invokeMethod: (NSString* _Nonnull) method arguments:(nullable id) arguments;

- (void) _handleMethodCall:(FlutterMethodCall* _Nonnull) call result:(FlutterResult _Nonnull)result;
@end
