import Cocoa
import FlutterMacOS
import kraken_method_channel

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    
    RegisterGeneratedPlugins(registry: flutterViewController)
    
    func handler(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
      KrakenMethodChannel.shared.invokeMethod(method: call.method, arguments: call.arguments)
      result("method: " + call.method)
    }
    
    KrakenMethodChannel.shared.setMessageHandler(handler)
    super.awakeFromNib()
  }
}
