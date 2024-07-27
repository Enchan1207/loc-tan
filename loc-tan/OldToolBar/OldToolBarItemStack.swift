//
//  OldToolBarItemStack.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/06/23.
//

import UIKit

/// ツールバーアイテムを配置するスタック
class OldToolBarItemStack: UIStackView {
    
    // MARK: - Properties
    
    /// ツールバーアイテムのリスト
    private var items: [OldToolBarItemType]
    
    weak var delegate: OldToolBarItemStackDelegate?
    
    // MARK: - Initializers
    
    init(items: [OldToolBarItemType]){
        self.items = items
        super.init(frame: .null)
        setup()
    }
    
    required init(coder: NSCoder) {
        self.items = coder.decodeObject(forKey: "items") as? [OldToolBarItemType] ?? []
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
    
    @objc private func onTapButton(_ sender: OldToolBarItem){
        delegate?.toolbarItemStack(self, didTapItem: sender.itemType)
    }
    
    /// ツールバーアイテムを強制的に初期化
    /// - Parameter buttonTypes: 配置するボタンタイプのリスト
    func resetButtons(_ buttonTypes: [OldToolBarItemType]) {
        self.arrangedSubviews.forEach({view in
            self.removeArrangedSubview(view)
            view.removeFromSuperview()
        })
        self.layoutIfNeeded()
        
        (Array(repeating: .none, count: max(2 - buttonTypes.count, 0)) + buttonTypes)
            .map({OldToolBarItem(itemType: $0)})
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
    func setButtons(_ types: [OldToolBarItemType], duration: TimeInterval) async {
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
