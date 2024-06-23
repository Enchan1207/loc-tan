//
//  ToolBarItemStack.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/06/23.
//

import UIKit

/// ツールバーアイテムを配置するスタック
class ToolBarItemStack: UIStackView {
    
    // MARK: - Properties
    
    /// ツールバーアイテムのリスト
    private var items: [ToolBarItemType]
    
    weak var delegate: ToolBarItemStackDelegate?
    
    // MARK: - Initializers
    
    init(items: [ToolBarItemType]){
        self.items = items
        super.init(frame: .null)
        setup()
    }
    
    required init(coder: NSCoder) {
        self.items = coder.decodeObject(forKey: "items") as? [ToolBarItemType] ?? []
        super.init(coder: coder)
        setup()
    }
    
    override func encode(with coder: NSCoder) {
        coder.encode(items, forKey: "items")
        super.encode(with: coder)
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(items, forKey: "items")
        super.encodeRestorableState(with: coder)
    }
    
    private func setup(){
        self.distribution = .equalSpacing
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // サブビューのセットアップ
        resetButtons(items)
    }
    
    // MARK: - Methods
    
    @objc private func onTapButton(_ sender: ToolBarItem){
        delegate?.toolbarItemStack(self, didTapItem: sender.itemType)
    }
    
    /// ツールバーアイテムを強制的に初期化
    /// - Parameter buttonTypes: 配置するボタンタイプのリスト
    func resetButtons(_ buttonTypes: [ToolBarItemType]) {
        self.arrangedSubviews.forEach({view in
            self.removeArrangedSubview(view)
            view.removeFromSuperview()
        })
        self.layoutIfNeeded()
        
        (Array(repeating: .none, count: max(2 - buttonTypes.count, 0)) + buttonTypes)
            .map({ToolBarItem(itemType: $0)})
            .forEach { item in
                item.addTarget(self, action: #selector(onTapButton), for: .touchUpInside)
                addArrangedSubview(item)
            }
        self.layoutIfNeeded()
    }
    
    /// ボタンを設定する
    /// - Parameters:
    ///   - types: 設定するボタンのタイプ
    ///   - duration: トランジション時間
    @MainActor
    func setButtons(_ types: [ToolBarItemType], duration: TimeInterval) async {
        // アイテムスタックごとユーザインタラクションを停止し、アルファをゼロに
        self.isUserInteractionEnabled = false
        await UIView.animate(withDuration: duration / 2.0) {
            self.alpha = 0
        }
        
        // すべてのボタンを再配置
        items = types
        resetButtons(items)
        
        // 再表示してユーザインタラクションを有効化
        await UIView.animate(withDuration: duration / 2.0) {
            self.alpha = 1
        }
        self.isUserInteractionEnabled = true
    }
    
}
