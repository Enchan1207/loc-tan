//
//  MainView.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/08/12.
//

import UIKit

class MainView: UIView {

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
        self.backgroundColor = .black
        
        // TODO: コンテナビュー構成
        // TODO: レイアウト制約構成
        // TODO: 各種ボタン実装
    }

}
