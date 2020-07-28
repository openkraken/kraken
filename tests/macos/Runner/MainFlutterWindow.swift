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
    let childKraken = Kraken.init(name: "child")
    
    mainKraken.registerMethodCallHandler({ (call: FlutterMethodCall, result: FlutterResult) in
      mainKraken.invokeMethod(call.method, arguments: call.arguments)
      result("method: " + call.method)
    })
    
    childKraken.registerMethodCallHandler({ (call: FlutterMethodCall, result: FlutterResult) in
      childKraken.invokeMethod(call.method, arguments: call.arguments)
      result("method: " + call.method)
    })
    
    super.awakeFromNib()
  }
}
