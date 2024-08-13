//
//  UIDeviceOrientationExt.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/08/13.
//

import UIKit

extension UIDeviceOrientation {
    
    /// デバイスの向きに応じた角度
    var rotationAngle: CGFloat {
        switch self {
        case .portrait:
            return 0.0
        case .portraitUpsideDown:
            return .pi
        case .landscapeLeft:
            return .pi / 2
        case .landscapeRight:
            return -(.pi / 2)
        default:
            return  0.0
        }
    }
    
}
