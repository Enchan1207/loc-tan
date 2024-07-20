//
//  OldOverlayObjectController.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/17.
//

import UIKit

class OldOverlayObjectController {
    
    let model: OldOverlayObjectModel
    
    let view: OldOverlayObjectView
    
    init(model: OldOverlayObjectModel) {
        self.model = model
        self.view = .init(image: model.image)
        updateViewPosition()
    }
    
    func move(to center: CGPoint) {
        model.center = center
        updateViewPosition()
    }
    
    private func updateViewPosition() {
        view.udpatePosition(to: model.center)
    }
    
    func select() {
        view.isSelected = true
    }
    
    func deselect() {
        view.isSelected = false
    }
    
}
