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
    
    private let itemStack = UIStackView()
    
    private let modeSwitcher = ToolBarModeSwitcher()
    
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
        self.translatesAutoresizingMaskIntoConstraints = false
        let containerView = setupContainer(base: self, margin: 10)
        setupItemStack(on: containerView)
        setupModeSwitcher(on: containerView)
    }
    
    private func setupContainer(base: UIView, margin: CGFloat) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        base.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: base.topAnchor, constant: margin),
            containerView.bottomAnchor.constraint(equalTo: base.bottomAnchor, constant: -margin),
            containerView.leftAnchor.constraint(equalTo: base.leftAnchor, constant: margin),
            containerView.rightAnchor.constraint(equalTo: base.rightAnchor, constant: -margin),
        ])
        return containerView
    }
    
    private func setupItemStack(on container: UIView){
        itemStack.distribution = .equalSpacing
        itemStack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(itemStack)
        NSLayoutConstraint.activate([
            itemStack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            itemStack.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.6),
            itemStack.heightAnchor.constraint(equalTo: container.heightAnchor),
            itemStack.rightAnchor.constraint(equalTo: container.rightAnchor)
        ])
    }
    
    private func setupModeSwitcher(on container: UIView){
        container.addSubview(modeSwitcher)
        NSLayoutConstraint.activate([
            modeSwitcher.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            modeSwitcher.leftAnchor.constraint(equalTo: container.leftAnchor),
            modeSwitcher.heightAnchor.constraint(equalTo: container.heightAnchor),
        ])
        modeSwitcher.addTarget(self, action: #selector(onTapSwitch), for: .touchUpInside)
    }
    
    // MARK: - Interface between ViewController
    
    func updateView(with model: ToolbarModel){
        modeSwitcher.updateView(mode: model.currentMode)
        setItemButtons(items: model.toolBarItems)
        self.layoutIfNeeded()
    }
    
    @MainActor
    func updateView(with model: ToolbarModel, duration: TimeInterval) async {
        self.modeSwitcher.isUserInteractionEnabled = false
        await withTaskGroup(of: Void.self) {[weak self] group in
            guard let `self` = self else {return}
            group.addTask { await self.modeSwitcher.updateView(mode: model.currentMode, duration: duration) }
            group.addTask { await self.updateItemStack(items: model.toolBarItems, duration: duration) }
        }
        self.modeSwitcher.isUserInteractionEnabled = true
    }
    
    @MainActor
    func updateItemStack(items: [ToolBarItem], duration: TimeInterval) async {
        itemStack.isUserInteractionEnabled = false
        await UIView.animate(withDuration: duration / 2.0) {
            self.itemStack.alpha = 0
        }
        setItemButtons(items: items)
        await UIView.animate(withDuration: duration / 2.0) {
            self.itemStack.alpha = 1
        }
        itemStack.isUserInteractionEnabled = true
    }
    
    private func setItemButtons(items: [ToolBarItem]){
        let itemViewsFromModel = items.map({item in
            let itemView = ToolBarItemView()
            itemView.item = item
            itemView.addTarget(self, action: #selector(onTapItem), for: .touchUpInside)
            return itemView
        })
        
        // アイテムビューが一つしかない場合は、スペーサになるビューをひとつ追加して返す
        let itemViews = (items.count == 1 ? [ToolBarItemView()] : []) + itemViewsFromModel
        
        itemStack.arrangedSubviews.forEach({view in
            itemStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        })
        itemViews.forEach(itemStack.addArrangedSubview)
    }
    
    @objc private func onTapSwitch(){
        delegate?.toolbarViewDidTapModeSwitcher(self)
    }
    
    @objc private func onTapItem(_ itemView: ToolBarItemView){
        delegate?.toolbarView(self, didTapItem: itemView.item)
    }
}
