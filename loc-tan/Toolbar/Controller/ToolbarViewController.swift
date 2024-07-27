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
    
    var delegate: ToolbarViewDelegate? {
        get { toolbarView.delegate }
        set { toolbarView.delegate = newValue }
    }
    
    override func loadView() {
        self.view = ToolbarView(frame: .zero)
        toolbarView.updateView(with: model)
    }
    
}

extension ToolbarViewController: ToolbarModelDelegate {
    
    func toolBarModel(_ model: ToolbarModel, didSwitchMode to: ToolbarMode) {
        toolbarView.updateView(with: model)
    }
    
}
