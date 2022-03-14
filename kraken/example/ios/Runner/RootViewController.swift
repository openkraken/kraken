//
//  RootViewController.swift
//  Runner
//
//  Created by lijin on 2022/3/14.
//

import Foundation
import Flutter

class RootViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(btn)
//        view.addSubview(multiEnginBtn)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        btn.frame = CGRect(x: 64, y: 134, width: 196, height: 52)
//        multiEnginBtn.frame = CGRect(x: btn.frame.minX,
//                                     y: btn.frame.maxY + 36,
//                                     width: 196, height: 52)
    }
    
    /// Actions
    @objc func jumpFlutterVC(_ btn: UIButton) -> Void {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            
            self.navigationController?.pushViewController(appDelegate.flutterVC(), animated: true)
        }
    }
    
    @objc func jumpMultipleEnginFlutterVC(_ btn: UIButton) {
        self.navigationController?.pushViewController(MultipuleEngineFlutterViewController(), animated: true)
    }
    
    /// Properties
    
    lazy var btn: UIButton = {
        let _btn = UIButton(type: .custom)
        _btn.setTitle("ShareInstance Engin", for: .normal)
        _btn.setTitleColor(.black, for: .normal)
        _btn.backgroundColor = .systemGreen
        _btn.addTarget(self, action: #selector(jumpFlutterVC(_:)), for: .touchUpInside)
        return _btn
    }()
    
    lazy var multiEnginBtn: UIButton = {
        let _btn = UIButton(type: .custom)
        _btn.setTitle("Multipule Engin", for: .normal)
        _btn.setTitleColor(.black, for: .normal)
        _btn.backgroundColor = .systemGreen
        _btn.addTarget(self, action: #selector(jumpMultipleEnginFlutterVC(_:)), for: .touchUpInside)
        return _btn
    }()
}
