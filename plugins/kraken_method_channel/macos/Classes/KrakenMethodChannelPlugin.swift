import Cocoa
import FlutterMacOS

public class KrakenMethodChannelPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "kraken_method_channel", binaryMessenger: registrar.messenger)
    let instance = KrakenMethodChannelPlugin()
    KrakenMethodChannel.shared.onAttach(KrakenMethodChannelPlugin: instance, channel: channel)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    KrakenMethodChannel.shared.handleMessageCall(call, result: result)
  }
}

func defaultHandler (_ call: FlutterMethodCall, result: @escaping FlutterResult) {}

public class KrakenMethodChannel: NSObject {
  private static let instance:KrakenMethodChannel = KrakenMethodChannel()
  private var krakenMethodChannelPlugin:KrakenMethodChannelPlugin?
  private var channel:FlutterMethodChannel?
  private var handler = defaultHandler;
  
  private override init() {
  }
  
  public static var shared:KrakenMethodChannel {
    return self.instance
  }
  
  public func invokeMethod(method: String, arguments: Any?) {
    if (self.krakenMethodChannelPlugin != nil) {
      DispatchQueue.main.async {
        self.channel?.invokeMethod(method, arguments: arguments)
      }
    }
  }
  
  public func setMessageHandler(_ handler: @escaping (_ call: FlutterMethodCall, _ result: @escaping FlutterResult) -> Void) {
    self.handler = handler
  }
  
  public func handleMessageCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    self.handler(call, result)
  }
  
  public func onAttach(KrakenMethodChannelPlugin:KrakenMethodChannelPlugin, channel:FlutterMethodChannel) {
    self.krakenMethodChannelPlugin = KrakenMethodChannelPlugin
    self.channel = channel
  }
}
