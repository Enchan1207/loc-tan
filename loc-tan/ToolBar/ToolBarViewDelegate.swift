//
//  ToolBarViewDelegate.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/06/23.
//

import Foundation

/// ツールバーの動作を通知するデリゲート
protocol ToolBarViewDelegate: AnyObject {
    
    /// ツールバーのモードが切り替わる前に呼ばれる
    /// - Parameters:
    ///   - view: ツールバー
    ///   - to: 切り替え後のモード
    func modeWillSwitch(_ view: ToolBarView, to mode: ToolBarMode)
    
    /// ツールバーのモードが切り替わった後に呼ばれる
    /// - Parameters:
    ///   - view: ツールバー
    ///   - to: 切り替え後のモード
    func modeDidSwitch(_ view: ToolBarView, to mode: ToolBarMode)
    
    /// ツールバー上のボタンが押された
    /// - Parameters:
    ///   - view: ツールバー
    ///   - type: 押されたボタンの種別
    func toolbar(_ view: ToolBarView, didTapItem type: ToolBarItemType)
    
}
