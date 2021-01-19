#import <Foundation/Foundation.h>
#import "Kraken.h"

static NSMutableArray *engineList = nil;
static NSMutableArray<Kraken*> *instanceList = nil;

@implementation Kraken

+ (Kraken*) instanceByBinaryMessenger: (NSObject<FlutterBinaryMessenger>*) messenger {
  for (int i = 0; i < engineList.count; i++) {
    FlutterEngine *engine = engineList[i];
    if (engine != nil && engine.viewController != nil && engine.viewController.binaryMessenger != nil) {
      if (engine.viewController.binaryMessenger == messenger) {
        return [instanceList objectAtIndex:i];
      }
    }
  }
  return nil;
}

- (instancetype)initWithFlutterEngine: (FlutterEngine*) engine {
  self.flutterEngine = engine;

  FlutterMethodChannel *channel = [KrakenPlugin getMethodChannel];

  if (channel == nil) {
    NSException* exception = [NSException
                              exceptionWithName:@"InitError"
                              reason:@"KrakenSDK should init after Flutter's plugin registered."
                              userInfo:nil];
    @throw exception;
  }
  self.channel = channel;

  if (engineList == nil) {
    engineList = [[NSMutableArray alloc] initWithCapacity: 0];
  }
  [engineList addObject: engine];

  if (instanceList == nil) {
    instanceList = [[NSMutableArray alloc] initWithCapacity: 0];
  }
  [instanceList addObject: self];

  return self;
}

- (void) loadUrl:(NSString*)url {
  if (url != nil) {
    self.bundleUrl = url;
  }
}

- (void) reload {
  if (self.channel != nil) {
    [self.channel invokeMethod:@"reload" arguments:nil];
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
      [self.channel invokeMethod:method arguments:arguments];
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


