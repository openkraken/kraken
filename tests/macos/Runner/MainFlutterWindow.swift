import Cocoa
import FlutterMacOS
import kraken_sdk

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    
    var kraken = Kraken.init(flutterEngine: flutterViewController.engine)

    func handler(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
      kraken?.invokeMethod(call.method, arguments: call.arguments)
      result("method: " + call.method)
    }
    kraken?.setValue(handler, forKey: "methodHandler")
    super.awakeFromNib()
  }
}
