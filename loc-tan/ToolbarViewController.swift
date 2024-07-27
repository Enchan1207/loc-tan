//
//  ToolbarViewController.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/27.
//

import UIKit

class ToolbarViewController: UIViewController {
    
    private let model: ToolbarModel
    
    // MARK: - Components
    
    private var toolbarView: ToolbarView { self.view as! ToolbarView }
    
    // MARK: - Initializing
    
    init(model: ToolbarModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        model.delegate = self
    }
    
    required init?(coder: NSCoder) {
        guard let model = coder.decodeObject(forKey: "model") as? ToolbarModel else {return nil}
        self.model = model
        super.init(coder: coder)
        model.delegate = self
    }
    
    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(model, forKey: "model")
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        coder.encode(model, forKey: "model")
    }
    
    // MARK: - View lifecycle
    
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
