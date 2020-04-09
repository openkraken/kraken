#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import <kraken/Kraken.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  FlutterEngine *engine = ((FlutterViewController*)self.window.rootViewController).engine;
  Kraken *kraken = [[Kraken alloc] initWithFlutterEngine:engine];
  [kraken loadUrl:@"https://dev.g.alicdn.com/kraken/kraken-demos/richtext/build/kraken/index.js"];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
