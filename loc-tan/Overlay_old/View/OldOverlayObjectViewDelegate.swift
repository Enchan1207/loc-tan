//
//  OldOverlayObjectViewDelegate.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/06/30.
//

import Foundation

/// オーバーレイオブジェクトのデリゲート
protocol OldOverlayObjectViewDelegate: AnyObject {
    
    /// オブジェクトが自身を操作対象にするよう要求した
    /// - Parameter sender: 操作を要求したオーバーレイオブジェクト
    func didRequireActivate(_ sender: OldOverlayObjectView)
    
}
