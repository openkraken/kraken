//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import camera
import connectivity_macos
import kraken_video_player
import shared_preferences_macos

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  CameraPlugin.register(with: registry.registrar(forPlugin: "CameraPlugin"))
  ConnectivityPlugin.register(with: registry.registrar(forPlugin: "ConnectivityPlugin"))
  FLTVideoPlayerPlugin.register(with: registry.registrar(forPlugin: "FLTVideoPlayerPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
}
