//
//  ToolBarItemType.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/06/22.
//

import Foundation

/// ツールバーボタンの種別
enum ToolBarItemType {
    
    /// オブジェクト回転
    case rotate
    
    /// オブジェクトリサイズ
    case resize
    
    /// オブジェクト追加
    case add
    
    /// 撮影設定
    case config
    
    /// 不可視のボタン (スペーサ用)
    case none
    
    /// ボタン種別に対応するSFシンボルの名前
    var symbolName: String {
        switch self {
        case .rotate:
            return "rotate.right"
        case .resize:
            return "arrow.up.backward.and.arrow.down.forward"
        case .add:
            return "plus.circle"
        case .config:
            return "gearshape"
        case .none:
            return ""
        }
    }
    
}
