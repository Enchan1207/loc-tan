//
//  CameraModel.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/08/13.
//

import Foundation

class CameraModel {
    
    weak var delegate: CameraModelDelegate?
    
    var aspectRatio: AspectRatio {
        didSet {
            delegate?.cameraModel(self, didChangeAspectRatio: aspectRatio)
        }
    }
    
    init(aspectRatio: AspectRatio) {
        self.aspectRatio = aspectRatio
    }
    
}
