import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    self.level = NSWindow.Level.floating;

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
