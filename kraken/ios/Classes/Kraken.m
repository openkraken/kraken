#import <Foundation/Foundation.h>
#import "Kraken.h"
#import <Flutter/FlutterViewController.h>

static NSMutableDictionary<NSString *, Kraken*> *instanceMap = nil;

@implementation Kraken

+ (Kraken*) instanceByName:(NSString*) name {
  return instanceMap[name];
}

- (instancetype _Nonnull)initWithName:(NSString*) name {
  self.name = name;
  
  FlutterMethodChannel *channel = [KrakenSDKPlugin getMethodChannel];
  
  if (channel == nil) {
    NSException* exception = [NSException
                              exceptionWithName:@"InitError"
                              reason:@"KrakenSDK should init after Flutter's plugin registered."
                              userInfo:nil];
    @throw exception;
  }
  self.channel = channel;
  
  if (instanceMap == nil) {
    instanceMap = [[NSMutableDictionary alloc] init];
  }
  [instanceMap setValue:self forKey:name];

  return self;
}

- (void) loadUrl:(NSString*)url {
  if (url != nil) {
    self.bundleUrl = url;
  }
}

- (void) reload {
  if (self.channel != nil) {
    [self invokeMethod:@"reload" arguments:nil];
  }
}

- (void) reloadWithUrl: (NSString*) url {
  [self loadUrl: url];
  [self reload];
}

- (NSString*) getUrl {
  return self.bundleUrl;
}

- (void) invokeMethod:(NSString *)method arguments:(nullable id) arguments {
  dispatch_async(dispatch_get_main_queue(), ^{
    if (self.channel != nil) {
      [self.channel invokeMethod:[NSString stringWithFormat:@"%@%@%@", self.name, NAME_METHOD_SPLIT, method] arguments:arguments];
    }
  });
}

- (void) _handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if (self.methodHandler != nil) {
    self.methodHandler(call, result);
  }
}

- (void) registerMethodCallHandler: (MethodHandler) handler {
  self.methodHandler = handler;
}

@end


