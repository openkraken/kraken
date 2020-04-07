//
//  Generated file. Do not edit.
//

#import "GeneratedPluginRegistrant.h"

#if __has_include(<connectivity/FLTConnectivityPlugin.h>)
#import <connectivity/FLTConnectivityPlugin.h>
#else
@import connectivity;
#endif

#if __has_include(<device_info/FLTDeviceInfoPlugin.h>)
#import <device_info/FLTDeviceInfoPlugin.h>
#else
@import device_info;
#endif

#if __has_include(<kraken_audioplayers/AudioplayersPlugin.h>)
#import <kraken_audioplayers/AudioplayersPlugin.h>
#else
@import kraken_audioplayers;
#endif

#if __has_include(<kraken_camera/CameraPlugin.h>)
#import <kraken_camera/CameraPlugin.h>
#else
@import kraken_camera;
#endif

#if __has_include(<kraken_geolocation/LocationPlugin.h>)
#import <kraken_geolocation/LocationPlugin.h>
#else
@import kraken_geolocation;
#endif

#if __has_include(<kraken_sdk/KrakenSDKPlugin.h>)
#import <kraken_sdk/KrakenSDKPlugin.h>
#else
@import kraken_sdk;
#endif

#if __has_include(<kraken_video_player/FLTVideoPlayerPlugin.h>)
#import <kraken_video_player/FLTVideoPlayerPlugin.h>
#else
@import kraken_video_player;
#endif

#if __has_include(<kraken_webview/FLTWebViewFlutterPlugin.h>)
#import <kraken_webview/FLTWebViewFlutterPlugin.h>
#else
@import kraken_webview;
#endif

#if __has_include(<path_provider/FLTPathProviderPlugin.h>)
#import <path_provider/FLTPathProviderPlugin.h>
#else
@import path_provider;
#endif

#if __has_include(<shared_preferences/FLTSharedPreferencesPlugin.h>)
#import <shared_preferences/FLTSharedPreferencesPlugin.h>
#else
@import shared_preferences;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FLTConnectivityPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTConnectivityPlugin"]];
  [FLTDeviceInfoPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTDeviceInfoPlugin"]];
  [AudioplayersPlugin registerWithRegistrar:[registry registrarForPlugin:@"AudioplayersPlugin"]];
  [CameraPlugin registerWithRegistrar:[registry registrarForPlugin:@"CameraPlugin"]];
  [LocationPlugin registerWithRegistrar:[registry registrarForPlugin:@"LocationPlugin"]];
  [KrakenSDKPlugin registerWithRegistrar:[registry registrarForPlugin:@"KrakenSDKPlugin"]];
  [FLTVideoPlayerPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTVideoPlayerPlugin"]];
  [FLTWebViewFlutterPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTWebViewFlutterPlugin"]];
  [FLTPathProviderPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTPathProviderPlugin"]];
  [FLTSharedPreferencesPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTSharedPreferencesPlugin"]];
}

@end
