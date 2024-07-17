//
//  OverlayObjectController.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/17.
//

import UIKit

class OverlayObjectController {
    
    let model: OverlayObjectModel
    
    let view: OverlayObjectView
    
    init(model: OverlayObjectModel) {
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
