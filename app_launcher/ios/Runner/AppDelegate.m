#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import <kraken/Kraken.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  Kraken *kraken = [[Kraken alloc] initWithName:@"main"];
  [kraken loadUrl:@"https://kraken.oss-cn-hangzhou.aliyuncs.com/data/app_bundle.zip"];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
