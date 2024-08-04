//
//  CameraViewControllerDelegate.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/08/04.
//

import UIKit

protocol CameraViewControllerDelegate: AnyObject {
    
    func cameraView(_ viewController: CameraViewController, didCapture image: UIImage)
    
    func cameraView(_ viewController: CameraViewController, didFailCapture error: Error?)
    
    func cameraView(_ viewController: CameraViewController, didChangeZoomFactor scale: CGFloat)
    
}
