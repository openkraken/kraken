//
//  MultipuleEngineFlutterViewController.swift
//  Runner
//
//  Created by lijin on 2022/3/14.
//

import Foundation

class MultipuleEngineFlutterViewController: UIViewController {
    
    lazy var topChildVC: SinegleEngineFlutterViewController? = {
        return SinegleEngineFlutterViewController(entrypoint: "top")
    }()
    lazy var bottomChildVC: SinegleEngineFlutterViewController? = {
        return SinegleEngineFlutterViewController(entrypoint: "bottom")
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGreen
        guard let topVC = topChildVC, let bottomVC = bottomChildVC else { return }
        self.addChild(topVC)
        self.addChild(bottomVC)
        var safeFrame = view.frame
        if #available(iOS 11.0, *) {
            safeFrame = view.safeAreaLayoutGuide.layoutFrame
        }
        let halfHeight = safeFrame.height / 2.0;
        
        topVC.view.frame = CGRect(x: safeFrame.minX, y: safeFrame.minY, width: safeFrame.width, height: halfHeight)
        bottomVC.view.frame = CGRect(x: safeFrame.minX, y: topVC.view.frame.maxY, width: safeFrame.width, height: halfHeight)
        view.addSubview(topVC.view)
        view.addSubview(bottomVC.view)
        topVC.didMove(toParent: self)
        bottomVC.didMove(toParent: self)
    }
    
}
