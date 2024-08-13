//
//  CameraModelDelegate.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/08/13.
//

import Foundation

protocol CameraModelDelegate: AnyObject {
    
    func cameraModel(_ model: CameraModel, didChangeAspectRatio aspectRatio: AspectRatio)
    
}
