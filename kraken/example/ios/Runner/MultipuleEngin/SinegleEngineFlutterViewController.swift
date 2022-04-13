//
//  SinegleEngineFlutterViewController.swift
//  Runner
//
//  Created by lijin on 2022/3/14.
//

import Foundation
import UIKit

class SinegleEngineFlutterViewController: FlutterViewController {
    
    var channel: FlutterMethodChannel?
    var map = [1: ["r": 255, "g": 0, "b": 0],
               2: ["r": 0, "g": 255, "b": 0],
               3: ["r": 0, "g": 0, "b": 255],
               4: ["r": 0, "g": 255, "b": 255],
               5: ["r": 255, "g": 0, "b": 255],
               6: ["r": 255, "g": 255, "b": 0],
    ]
    var count = 1
    
    convenience init?(entrypoint: String?) {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate,
        let engine = appdelegate.flutterEngine(withEntrypoint: entrypoint, libraryURI: nil) else { return nil }
        self.init(engine: engine, nibName: nil, bundle: nil)
        GeneratedPluginRegistrant.register(with: pluginRegistry())
        self.channel = FlutterMethodChannel(name: "devchannel", binaryMessenger: self.engine!.binaryMessenger)
        self.channel?.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            if call.method == "test1" {
                self?.methodShow()
            } else if call.method == "test2" {
                self?.methodt2()
            } else if call.method == "changeColor" {
                guard self != nil else { return }
                if self!.count > 6 {
                    self!.count = 1
                }
                result(self!.map[self!.count])
                self!.count += 1
            } else {
                result(FlutterMethodNotImplemented)
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func methodShow() -> Void {
        guard let showView = view.viewWithTag(101) else {
            print("Flutter Show Method: showView init")
            let tagView = UIView(frame: CGRect(x: 10, y: 84, width: 40, height: 40))
            tagView.tag = 101
            tagView.backgroundColor = UIColor.blue
            view.addSubview(tagView)
            return
        }
        showView.removeFromSuperview()
    }
    
    func methodt2() -> Void {
        print("Flutter Test 2")
    }
    
    func getColor() -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: ["r": 255, "g": 0, "b": 0], options: .prettyPrinted) else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    deinit {
        print("---------dealloc--------")
    }
}
