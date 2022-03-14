//
//  SinegleEngineFlutterViewController.swift
//  Runner
//
//  Created by lijin on 2022/3/14.
//

import Foundation

class SinegleEngineFlutterViewController: FlutterViewController {
    
    var channel: FlutterMethodChannel?
    
    convenience init?(entrypoint: String?) {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate,
        let engine = appdelegate.flutterEngine(withEntrypoint: entrypoint, libraryURI: nil) else { return nil }
        GeneratedPluginRegistrant.register(with: engine)
        self.init(engine: engine, nibName: nil, bundle: nil)
        self.channel = FlutterMethodChannel(name: "kraken", binaryMessenger: self.engine!.binaryMessenger)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
