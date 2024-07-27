//
//  OldToolBarViewDelegate.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/06/23.
//

import Foundation

/// ツールバーの動作を通知するデリゲート
protocol OldToolBarViewDelegate: AnyObject {
    
    /// ツールバーのモードが切り替わる前に呼ばれる
    /// - Parameters:
    ///   - view: ツールバー
    ///   - to: 切り替え後のモード
    func modeWillSwitch(_ view: OldToolBarView, to mode: OldToolBarMode)
    
    /// ツールバーのモードが切り替わった後に呼ばれる
    /// - Parameters:
    ///   - view: ツールバー
    ///   - to: 切り替え後のモード
    func modeDidSwitch(_ view: OldToolBarView, to mode: OldToolBarMode)
    
    /// ツールバー上のボタンが押された
    /// - Parameters:
    ///   - view: ツールバー
    ///   - type: 押されたボタンの種別
    func toolbar(_ view: OldToolBarView, didTapItem type: OldToolBarItemType)
    
}
