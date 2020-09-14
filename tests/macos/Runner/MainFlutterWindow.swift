import Cocoa
import FlutterMacOS
import kraken

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    let kraken = Kraken.init(flutterEngine: flutterViewController.engine)

    kraken.registerMethodCallHandler({ (call: FlutterMethodCall, result: FlutterResult) in
      kraken.invokeMethod(call.method, arguments: call.arguments)
      result("method: " + call.method)
    })

    super.awakeFromNib()
  }
}
