#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import <kraken/Kraken.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  FlutterEngine *engine = ((FlutterViewController*)self.window.rootViewController).engine;
  Kraken *kraken = [[Kraken alloc] initWithFlutterEngine:engine];
  [kraken loadUrl:@"https://kraken.oss-cn-hangzhou.aliyuncs.com/data/app_bundle.zip"];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
