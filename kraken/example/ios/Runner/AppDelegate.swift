import UIKit
import Flutter
import YKWoodpecker

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    /// static engine
    func flutterEngin() -> FlutterEngine {
        return _flutterEngin
    }
    
    func flutterVC() -> FlutterViewController {
        let vc = FlutterViewController(engine: flutterEngin(), nibName: nil, bundle: nil);
        return vc
    }
    
    /// multipule engines
    func flutterEnginesGroup() -> FlutterEngineGroup {
        return _flutterEngineGroup
    }
    
    func flutterEngine(withEntrypoint: String?, libraryURI: String?) -> FlutterEngine? {
        return flutterEnginesGroup().makeEngine(withEntrypoint: withEntrypoint, libraryURI: libraryURI)
    }
    
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      let navi = UINavigationController(rootViewController: RootViewController())
      self.window.rootViewController = navi
      window.makeKeyAndVisible()
      YKWoodpeckerManager.sharedInstance().show()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    /// Lazy Loader
    private lazy var _flutterEngineGroup: FlutterEngineGroup = {
        let group: FlutterEngineGroup = FlutterEngineGroup(name: "com.openkraken.group.org", project: nil)
        return group
    }()
    
    private lazy var _flutterEngin: FlutterEngine = {
        let engin = FlutterEngine(name: "com.openkraken.org", project: nil)
        engin.run()
        GeneratedPluginRegistrant.register(with: engin)
        return engin
    }()
}

public extension DispatchQueue {
    private static var _onceTracker = [String]()

    class func once(file: String = #file, function: String = #function, line: Int = #line, block:()->Void) {
        let token = file + ":" + function + ":" + String(line)
        once(token: token, block: block)
    }

    class func once(token: String, block:()->Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }


        if _onceTracker.contains(token) {
            return
        }

        _onceTracker.append(token)
        block()
    }
}

