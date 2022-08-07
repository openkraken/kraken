#import <Foundation/Foundation.h>
#import "WebF.h"
#import "WebFPlugin.h"

static NSMutableArray *engineList = nil;
static NSMutableArray<WebF*> *instanceList = nil;

@implementation WebF

+ (WebF*) instanceByBinaryMessenger: (NSObject<FlutterBinaryMessenger>*) messenger {
  // Return last instance, multi instance not supported yet.
  if (instanceList != nil && instanceList.count > 0) {
    return [instanceList objectAtIndex: instanceList.count - 1];
  }
  return nil;
}

- (instancetype)initWithFlutterEngine: (FlutterEngine*) engine {
  self.flutterEngine = engine;

  FlutterMethodChannel *channel = [WebFPlugin getMethodChannel];

  if (channel == nil) {
    NSException* exception = [NSException
                                exceptionWithName:@"InitError"
                                reason:@"WebFSDK should init after Flutter's plugin registered."
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


