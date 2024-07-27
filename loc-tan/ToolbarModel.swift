//
//  ToolbarModel.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/27.
//

import Foundation

enum ToolbarMode {
    case Camera
    case Edit
    
    var opposite: ToolbarMode {
        self == .Camera ? .Edit : .Camera
    }
}

enum ToolBarItem {
    case Settings
    case Rotate
    case Fullsize
    case Add
}

protocol ToolbarModelDelegate: AnyObject {
    
    func toolBarModel(_ model: ToolbarModel, didSwitchMode to: ToolbarMode)
    
}

class ToolbarModel {
    
    private(set) var currentMode: ToolbarMode
    
    weak var delegate: ToolbarModelDelegate?
    
    init(mode: ToolbarMode) {
        self.currentMode = mode
    }
    
    func setMode(_ mode: ToolbarMode){
        self.currentMode = mode
        self.delegate?.toolBarModel(self, didSwitchMode: mode)
    }
    
    var toolBarItems: [ToolBarItem] {
        switch currentMode {
        case .Camera:
            return [.Settings]
        case .Edit:
            return [.Rotate, .Fullsize, .Add]
        }
    }
    
}
