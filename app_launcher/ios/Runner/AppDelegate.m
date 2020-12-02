#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import <kraken/Kraken.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  FlutterViewController* vc = (FlutterViewController*)self.window.rootViewController;
    
  Kraken *kraken = [[Kraken alloc] initWithFlutterEngine:vc.engine];
  [kraken loadUrl:@"https://kraken.oss-cn-hangzhou.aliyuncs.com/data/app_bundle.zip"];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
