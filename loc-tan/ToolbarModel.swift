//
//  ToolbarModel.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/27.
//

import Foundation

enum Mode {
    case Camera
    case Edit
    
    var opposite: Mode {
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
    
    func toolBarModel(_ model: ToolbarModel, didSwitchMode to: Mode)
    
}

class ToolbarModel {
    
    private(set) var currentMode: Mode
    
    weak var delegate: ToolbarModelDelegate?
    
    init(mode: Mode) {
        self.currentMode = mode
    }
    
    func switchMode(to mode: Mode){
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
