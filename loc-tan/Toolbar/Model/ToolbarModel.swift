//
//  ToolbarModel.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/27.
//

import Foundation

enum ToolbarMode {
    case camera
    case edit
    
    var opposite: ToolbarMode {
        self == .camera ? .edit : .camera
    }
}

enum ToolBarItem {
    case aspectRatio
    case rotate
    case expandToFullScreen
    case add
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
        case .camera:
            return [.aspectRatio]
        case .edit:
            return [.rotate, .expandToFullScreen, .add]
        }
    }
    
}
