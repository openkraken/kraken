//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import connectivity_macos
import kraken
import kraken_devtools
import kraken_websocket
import shared_preferences_macos

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  ConnectivityPlugin.register(with: registry.registrar(forPlugin: "ConnectivityPlugin"))
  KrakenPlugin.register(with: registry.registrar(forPlugin: "KrakenPlugin"))
  KrakenDevtoolsPlugin.register(with: registry.registrar(forPlugin: "KrakenDevtoolsPlugin"))
  KrakenWebsocketPlugin.register(with: registry.registrar(forPlugin: "KrakenWebsocketPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
}
