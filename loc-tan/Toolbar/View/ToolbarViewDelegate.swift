//
//  ToolbarViewDelegate.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/27.
//

import Foundation

protocol ToolbarViewDelegate: AnyObject {
    
    func toolbarView(_ view: ToolbarView, didTapItem item: ToolBarItem)
    
    func toolbarViewDidTapModeSwitcher(_ view: ToolbarView)
    
}
