//
//  CGRectExt.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/08/04.
//

import CoreGraphics

extension CGRect {
    
    // rectをsize倍して返す
    func mapped(to size: CGSize) -> CGRect {
        return .init(
            x: origin.x * size.width,
            y: origin.y * size.height,
            width: width * size.width,
            height: height * size.height)
    }
    
}
