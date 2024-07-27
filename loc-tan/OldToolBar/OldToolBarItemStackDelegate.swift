//
//  OldToolBarItemStackDelegate.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/06/23.
//

import Foundation

protocol OldToolBarItemStackDelegate: AnyObject {
    
    /// ツールバーアイテムスタック上でアイテムがタップされた
    /// - Parameters:
    ///   - itemStack: アイテムスタック
    ///   - type: タップされたアイテムのタイプ
    func toolbarItemStack(_ itemStack: OldToolBarItemStack, didTapItem type: OldToolBarItemType)
    
}
