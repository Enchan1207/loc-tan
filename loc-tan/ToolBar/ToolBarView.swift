//
//  ToolBarView.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/06/23.
//

import UIKit

/// 画面上端に表示されるツールバー
class ToolBarView: UIView {
    
    // MARK: - Properties
    
    /// 現在のモード
    private var currentMode: ToolBarMode = .normal
    
    /// デリゲート
    weak var delegate: ToolBarViewDelegate?
    
    /// モード別ツールバーアイテムリスト
    private let buttonTypes: [ToolBarMode: [ToolBarItemType]] = [
        .normal: [.config],
        .edit: [.rotate, .resize, .add]
    ]
    
    // MARK: - GUI Components
    
    /// サブアイテムを配置するスタック
    private let itemStack: ToolBarItemStack
    
    /// モードスイッチャ
    private let modeSwitcher: ToolBarModeSwitcher
    
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        self.itemStack = .init(items: buttonTypes[currentMode] ?? [])
        self.modeSwitcher = .init(mode: currentMode)
        
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        self.itemStack = .init(items: buttonTypes[currentMode] ?? [])
        self.modeSwitcher = .init(mode: currentMode)
        
        super.init(coder: coder)
        setup()
    }
    
    /// ビューのセットアップ
    private func setup(){
        // サブアイテムスタックを構成
        self.addSubview(itemStack)
        NSLayoutConstraint.activate([
            itemStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            itemStack.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6),
            itemStack.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8),
            itemStack.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        itemStack.resetButtons(buttonTypes[currentMode] ?? [])
        
        // モードスイッチャを構成
        self.addSubview(modeSwitcher)
        NSLayoutConstraint.activate([
            modeSwitcher.centerYAnchor.constraint(equalTo: centerYAnchor),
            modeSwitcher.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8),
            modeSwitcher.leftAnchor.constraint(equalTo: leftAnchor)
        ])
        modeSwitcher.addTarget(self, action: #selector(onTapModeSwitcher), for: .touchUpInside)
        
    }
    
    @objc private func onTapModeSwitcher(_ sender: ToolBarModeSwitcher) {
        currentMode = currentMode == .normal ? .edit : .normal
        let animationDuration = 0.2
        
        Task{
            await withTaskGroup(of: Void.self) {[weak self] group in
                guard let `self` = self else {return}
                group.addTask { await sender.switchMode(to: self.currentMode, duration: animationDuration) }
                group.addTask { await self.itemStack.setButtons(self.buttonTypes[self.currentMode] ?? [], duration: animationDuration) }
            }
        }
        
    }
    
}
