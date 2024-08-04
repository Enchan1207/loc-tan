//
//  ToolbarModelDelegate.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/27.
//

import Foundation

protocol ToolbarModelDelegate: AnyObject {
    
    func toolBarModel(_ model: ToolbarModel, didSwitchMode to: ToolbarMode)
    
}
