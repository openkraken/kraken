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
    [self.channel invokeMethod:method arguments:arguments];
  });
}

- (void) _handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if (self.methodHandler != nil) {
   self.methodHandler(call, result);
  }
}

@end


