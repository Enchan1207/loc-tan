//
//  ToolBarViewDataSource.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/06/27.
//

import Foundation

protocol ToolBarViewDataSource: AnyObject {
    
    /// モードに対応するツールバーアイテムを返す
    /// - Parameters:
    ///   - view: ツールバー
    ///   - mode: 対象のモード
    /// - Returns: モードに紐づくボタンタイプのリスト
    func toolbar(_ view: ToolBarView, buttonTypesFor mode: ToolBarMode) -> [ToolBarItemType]
    
}
