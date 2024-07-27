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
    
    private let topBar = UINavigationBar()
    
    private let topBarItem = UINavigationItem()
    
    // MARK: - Initializing
    
    init(model: ToolbarModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        guard let model = coder.decodeObject(forKey: "model") as? ToolbarModel else {return nil}
        self.model = model
        super.init(coder: coder)
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
        self.view = .init(frame: .zero)
        self.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.delegate = self
        
        // TODO: View層に逃がす
        topBar.setItems([topBarItem], animated: false)
        topBarItem.leftBarButtonItem = .init(image: model.currentMode.symbolImage, style: .plain, target: self, action: #selector(onTapSwitch))
        topBarItem.rightBarButtonItems = model.toolBarItems.map(makeBarButton)
        
        view.addSubview(topBar)
        topBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topBar.topAnchor),
            view.bottomAnchor.constraint(equalTo: topBar.bottomAnchor),
            view.leftAnchor.constraint(equalTo: topBar.leftAnchor),
            view.rightAnchor.constraint(equalTo: topBar.rightAnchor),
        ])
    }
    
    // MARK: - Methods
    
    private func makeBarButton(for item: ToolBarItem) -> UIBarButtonItem {
        let barButtonItem = UIBarButtonItem(image: item.symbolImage, style: .plain, target: self, action: #selector(onTapItem))
        barButtonItem.tag = item.tagValue
        return barButtonItem
    }
    
    // MARK: - Event handlers
    
    @objc private func onTapSwitch(_ item: UIBarButtonItem){
        model.switchMode(to: model.currentMode.opposite)
    }
    
    @objc private func onTapItem(_ item: UIBarButtonItem){
        guard let tappedItem = ToolBarItem(tagValue: item.tag) else {
            print("Warning: unexpected tag value: \(item.tag)")
            return
        }
        
        switch tappedItem {
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

}

extension ToolbarViewController: ToolbarModelDelegate {

    func toolBarModel(_ model: ToolbarModel, didSwitchMode to: Mode) {
        topBarItem.leftBarButtonItem = .init(image: to.symbolImage, style: .plain, target: self, action: #selector(onTapSwitch))
        topBarItem.rightBarButtonItems = model.toolBarItems.map(makeBarButton)
    }
    
}

fileprivate extension Mode {
    
    var symbolImage: UIImage {
        let symbolIdentifiers: [Mode: String] = [
            .Camera: "square.2.layers.3d.top.filled",
            .Edit: "square.2.layers.3d.bottom.filled"
        ]
        return .init(systemName: symbolIdentifiers[self]!)!
    }
    
}

fileprivate extension ToolBarItem {
    
    var tagValue: Int {
        switch self {
        case .Settings:
            return 1
        case .Rotate:
            return 2
        case .Fullsize:
            return 3
        case .Add:
            return 4
        }
    }
    
    init?(tagValue: Int){
        switch tagValue {
        case 1:
            self = .Settings
        case 2:
            self = .Rotate
        case 3:
            self = .Fullsize
        case 4:
            self = .Add
        default:
            return nil
        }
    }
    
    var symbolImage: UIImage {
        let symbolIdentifiers: String
        switch self {
        case .Settings:
            symbolIdentifiers = "gearshape"
        case .Rotate:
            symbolIdentifiers = "rotate.right"
        case .Fullsize:
            symbolIdentifiers = "arrow.up.left.and.arrow.down.right"
        case .Add:
            symbolIdentifiers = "plus.circle"
        }
        return .init(systemName: symbolIdentifiers)!
    }
    
}
