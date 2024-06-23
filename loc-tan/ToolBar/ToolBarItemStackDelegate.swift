//
//  ToolBarItemStackDelegate.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/06/23.
//

import Foundation

protocol ToolBarItemStackDelegate: AnyObject {
    
    /// ツールバーアイテムスタック上でアイテムがタップされた
    /// - Parameters:
    ///   - itemStack: アイテムスタック
    ///   - type: タップされたアイテムのタイプ
    func toolbarItemStack(_ itemStack: ToolBarItemStack, didTapItem type: ToolBarItemType)
    
}
