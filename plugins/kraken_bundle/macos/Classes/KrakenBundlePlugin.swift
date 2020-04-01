import Cocoa
import FlutterMacOS

public class KrakenBundlePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "kraken_bundle", binaryMessenger: registrar.messenger)
    let instance = KrakenBundlePlugin()
    KrakenBundleManager.shared.onAttach(krakenBundlePlugin: instance, channel: channel)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getBundleUrl":
      result(KrakenBundleManager.shared.getBundleUrl())
    case "getZipBundleUrl":
      result(KrakenBundleManager.shared.getZipBundleUrl())
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
