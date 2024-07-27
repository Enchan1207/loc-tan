//
//  ToolbarView.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/27.
//

import UIKit

class ToolbarView: UIView {
    
    weak var delegate: ToolbarViewDelegate?
    
    // MARK: - Components
    
    private let topBar = UINavigationBar()
    
    private let topBarItem = UINavigationItem()
    
    // MARK: - Initializing
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup(){
        topBar.setItems([topBarItem], animated: false)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topBar)
        topBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: topBar.topAnchor),
            bottomAnchor.constraint(equalTo: topBar.bottomAnchor),
            leftAnchor.constraint(equalTo: topBar.leftAnchor),
            rightAnchor.constraint(equalTo: topBar.rightAnchor),
        ])
    }
    
    func updateView(with model: ToolbarModel){
        topBarItem.leftBarButtonItem = .init(image: model.currentMode.symbolImage, style: .plain, target: self, action: #selector(onTapSwitch))
        topBarItem.rightBarButtonItems = model.toolBarItems.map({item in
            let barButtonItem = UIBarButtonItem(image: item.symbolImage, style: .plain, target: self, action: #selector(onTapItem))
            barButtonItem.tag = item.tagValue
            return barButtonItem
        })
    }
    
    @objc private func onTapSwitch(_ item: UIBarButtonItem){
        delegate?.toolbarViewDidTapModeSwitcher(self)
    }
    
    @objc private func onTapItem(_ item: UIBarButtonItem){
        guard let tappedItem = ToolBarItem(tagValue: item.tag) else {
            print("Warning: unexpected tag value: \(item.tag)")
            return
        }
        delegate?.toolbarView(self, didTapItem: tappedItem)
    }
}


fileprivate extension ToolbarMode {
    
    var symbolImage: UIImage {
        let symbolName: String
        switch self {
        case .Camera:
            symbolName = "square.2.layers.3d.top.filled"
        case .Edit:
            symbolName = "square.2.layers.3d.bottom.filled"
        }
        return .init(systemName: symbolName)!
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
        let symbolName: String
        switch self {
        case .Settings:
            symbolName = "gearshape"
        case .Rotate:
            symbolName = "rotate.right"
        case .Fullsize:
            symbolName = "arrow.up.left.and.arrow.down.right"
        case .Add:
            symbolName = "plus.circle"
        }
        return .init(systemName: symbolName)!
    }
    
}
