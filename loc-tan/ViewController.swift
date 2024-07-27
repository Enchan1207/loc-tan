//
//  ViewController.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/06/15.
//

import UIKit

class ViewController: UIViewController {
    
    private let model = ToolbarModel(mode: .Camera)
    
    private let toolbarViewController = ToolbarViewController()
    
    override var prefersStatusBarHidden: Bool {true}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toolbarViewController.model = model
        addChild(toolbarViewController)
        view.addSubview(toolbarViewController.view)
        NSLayoutConstraint.activate([
            view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: toolbarViewController.view.topAnchor),
            view.safeAreaLayoutGuide.leftAnchor.constraint(equalTo: toolbarViewController.view.leftAnchor),
            view.safeAreaLayoutGuide.rightAnchor.constraint(equalTo: toolbarViewController.view.rightAnchor),
        ])
        toolbarViewController.didMove(toParent: self)
    }
}
