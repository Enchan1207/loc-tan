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
        toolbarViewController.delegate = self
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

extension ViewController: ToolbarViewDelegate {
    
    func toolbarView(_ view: ToolbarView, didTapItem item: ToolBarItem) {
        switch item {
        case .Settings:
            print("Camera settings")
        case .Rotate:
            print("Rotate image")
        case .Fullsize:
            print("Set image fullsize")
        case .Add:
            print("Add new image")
        }
    }
    
    func toolbarViewDidTapModeSwitcher(_ view: ToolbarView) {
        model.setMode(model.currentMode.opposite)
    }
    
}
