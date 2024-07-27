//
//  ToolbarViewController.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/27.
//

import UIKit

class ToolbarViewController: UIViewController {
    
    var model: ToolbarModel! {
        didSet {
            model.delegate = self
            toolbarView.updateView(with: model)
        }
    }
    
    private var toolbarView: ToolbarView { self.view as! ToolbarView }
    
    override func loadView() {
        self.view = ToolbarView(frame: .zero)
        toolbarView.updateView(with: model)
        toolbarView.translatesAutoresizingMaskIntoConstraints = false
        toolbarView.delegate = self
    }
    
}

extension ToolbarViewController: ToolbarModelDelegate {
    
    func toolBarModel(_ model: ToolbarModel, didSwitchMode to: ToolbarMode) {
        toolbarView.updateView(with: model)
    }
    
}

extension ToolbarViewController: ToolbarViewDelegate {
    
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
