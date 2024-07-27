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
        let toolbarView = toolbarViewController.view!
        view.addSubview(toolbarView)
        NSLayoutConstraint.activate([
            view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: toolbarView.topAnchor),
            view.safeAreaLayoutGuide.leftAnchor.constraint(equalTo: toolbarView.leftAnchor),
            view.safeAreaLayoutGuide.rightAnchor.constraint(equalTo: toolbarView.rightAnchor),
            toolbarView.heightAnchor.constraint(equalToConstant: 55)
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
