#import <Foundation/Foundation.h>
#import "Kraken.h"

@implementation Kraken

static NSMutableDictionary *sdkMap;

+ (Kraken*) get: (NSString*) isolateId {
  return [sdkMap objectForKey:isolateId];
}

- (instancetype)initWithFlutterEngine: (FlutterEngine*) engine {
  self.flutterEngine = engine;
  NSLog(@"engine islateId %@", engine.isolateId);
  [sdkMap setValue:self forKey:engine.isolateId];
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

@end


