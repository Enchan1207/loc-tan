//
//  OldToolBarItem.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/06/23.
//

import UIKit

/// ツールバー上のボタン
class OldToolBarItem: UIButton {
    
    /// ボタンの種別
    let itemType: OldToolBarItemType
    
    override var buttonType: UIButton.ButtonType { .custom }
    
    // MARK: - Initializers
    
    init(itemType: OldToolBarItemType){
        self.itemType = itemType
        super.init(frame: .null)
        setup()
    }
    
    required init?(coder: NSCoder) {
        self.itemType = (coder.decodeObject(forKey: "type") as? OldToolBarItemType) ?? .none
        super.init(coder: coder)
        setup()
    }
    
    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(itemType, forKey: "type")
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        coder.encode(itemType, forKey: "type")
    }
    
    /// ツールバーボタンを構成する
    private func setup(){
        self.translatesAutoresizingMaskIntoConstraints = false
        self.imageView!.translatesAutoresizingMaskIntoConstraints = false
        self.imageView!.contentMode = .scaleAspectFit
        
        // タイプに合った画像を割り当てる
        self.setImage(.init(systemName: itemType.symbolName), for: .normal)
        
        // .noneなら隠す
        alpha = itemType != .none ? 1.0 : 0.0
        isEnabled = itemType != .none
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        guard let superview = superview else {return}
        
        // 制約を設定 親(=ツールバーアイテムのスタック) と同じ高さで、アス比は1:1
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalTo: superview.heightAnchor),
            widthAnchor.constraint(equalTo: heightAnchor),
            imageView!.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView!.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView!.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6),
            imageView!.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6)
        ])
    }
    
}
