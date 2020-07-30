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
    
    let mainKraken = Kraken.init(name: "main")
    let secondaryKraken = Kraken.init(name: "secondary")
    
    mainKraken.registerMethodCallHandler({ (call: FlutterMethodCall, result: FlutterResult) in
      mainKraken.invokeMethod(call.method, arguments: call.arguments)
      result("method: " + call.method)
    })
    
    secondaryKraken.registerMethodCallHandler({ (call: FlutterMethodCall, result: FlutterResult) in
      secondaryKraken.invokeMethod(call.method, arguments: call.arguments)
      result("method: " + call.method)
    })
    
    super.awakeFromNib()
  }
}
