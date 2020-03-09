//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import audioplayers
import camera
import connectivity_macos
import kraken_video_player
import location
import path_provider_macos
import shared_preferences_macos

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  AudioplayersPlugin.register(with: registry.registrar(forPlugin: "AudioplayersPlugin"))
  CameraPlugin.register(with: registry.registrar(forPlugin: "CameraPlugin"))
  ConnectivityPlugin.register(with: registry.registrar(forPlugin: "ConnectivityPlugin"))
  FLTVideoPlayerPlugin.register(with: registry.registrar(forPlugin: "FLTVideoPlayerPlugin"))
  LocationPlugin.register(with: registry.registrar(forPlugin: "LocationPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
}
